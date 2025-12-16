
# Enkrypt Module - Modern Envelope Encryption for Windows
# Version: 2.0.0
# Requires: PowerShell 7+ or .NET Framework 4.7+ with AesGcm (Standard in .NET Core 2.1+)

# Core Encryption Constants
$Global:EnkryptConfig = @{
    Version       = "2.0"
    KeySize       = 32 # 256-bit
    NonceSize     = 12 # 96-bit (Standard for GCM)
    TagSize       = 16 # 128-bit (Standard for GCM)
    KeyProtection = "DPAPI-CurrentUser"
}

function New-EnkryptKey {
    <#
    .SYNOPSIS
        Generates a secure random 256-bit AES key.
    .OUTPUTS
        byte[]
    #>
    [CmdletBinding()]
    param()
    
    $Key = New-Object byte[] $Global:EnkryptConfig.KeySize
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($Key)
    return $Key
}

function Protect-EnkryptKey {
    <#
    .SYNOPSIS
        Wraps a raw AES key using DPAPI (CurrentUser).
    .INPUTS
        byte[] (The raw key)
    .OUTPUTS
        string (Base64 wrapper)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [byte[]]$RawKey
    )

    Add-Type -AssemblyName System.Security

    $ProtectedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
        $RawKey,
        $null,
        [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    
    return [Convert]::ToBase64String($ProtectedBytes)
}

function Unprotect-EnkryptKey {
    <#
    .SYNOPSIS
        Unwraps a DPAPI-protected key.
    .INPUTS
        string (Base64 wrapper)
    .OUTPUTS
        byte[] (The raw key)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$WrappedKeyBase64
    )

    Add-Type -AssemblyName System.Security
    
    $ProtectedBytes = [Convert]::FromBase64String($WrappedKeyBase64)
    
    try {
        $RawKey = [System.Security.Cryptography.ProtectedData]::Unprotect(
            $ProtectedBytes,
            $null,
            [System.Security.Cryptography.DataProtectionScope]::CurrentUser
        )
        return $RawKey
    }
    catch {
        Write-Error "Failed to unwrap key. Ensure you are the same user on the same machine that encrypted this file."
        throw $_
    }
}

function Protect-File {
    <#
    .SYNOPSIS
        Encrypts a file using AES-256-GCM and wraps the key with DPAPI.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Destination
    )

    $Path = Resolve-Path $Path
    if (-not (Test-Path $Path)) { throw "File not found: $Path" }

    # 1. Generate DEK (Data Encryption Key)
    $DEK = New-EnkryptKey

    # 2. Encrypt Content
    try {
        $PlainBytes = [System.IO.File]::ReadAllBytes($Path)
        
        # Prepare GCM
        $Nonce = New-Object byte[] $Global:EnkryptConfig.NonceSize
        [System.Security.Cryptography.RandomNumberGenerator]::Fill($Nonce)
        
        $CipherBytes = New-Object byte[] $PlainBytes.Length
        $Tag = New-Object byte[] $Global:EnkryptConfig.TagSize
        
        # Validating .NET Core / Framework compatibility
        # If AesGcm is strictly not available, this script will fail here.
        
        $AesGcm = New-Object System.Security.Cryptography.AesGcm($DEK, $Global:EnkryptConfig.TagSize)
        $AesGcm.Encrypt($Nonce, $PlainBytes, $CipherBytes, $Tag, $null) # AAD is null
        $AesGcm.Dispose() # manual dispose

    }
    catch {
        throw "Encryption primitive failed. Standard .NET AesGcm is required. $_"
    }

    # 3. Key Wrapping
    $WrappedKey = Protect-EnkryptKey -RawKey $DEK

    # 4. Construct Header
    $Header = @{
        format        = "enkrypt"
        version       = $Global:EnkryptConfig.Version
        cipher        = "AES-256-GCM"
        keyProtection = $Global:EnkryptConfig.KeyProtection
        timestamp     = (Get-Date).ToString("u")
        iv            = [Convert]::ToBase64String($Nonce)
        authTag       = [Convert]::ToBase64String($Tag)
        wrappedKey    = $WrappedKey
    }

    $HeaderJson = $Header | ConvertTo-Json -Compress
    $HeaderBytes = [System.Text.Encoding]::UTF8.GetBytes($HeaderJson)
    
    # 5. Write binary format: [4-byte Header Length][Header JSON][Ciphertext]
    # This creates a parsable binary stream.
    
    $fs = [System.IO.File]::Create($Destination)
    
    # Write Length Prefix (Int32 Little Endian)
    $LenBytes = [BitConverter]::GetBytes([int]$HeaderBytes.Length)
    $fs.Write($LenBytes, 0, 4)
    
    # Write Header
    $fs.Write($HeaderBytes, 0, $HeaderBytes.Length)
    
    # Write Body (Ciphertext)
    $fs.Write($CipherBytes, 0, $CipherBytes.Length)
    
    $fs.Flush()
    $fs.Dispose()
    
    Write-Verbose "Encrypted '$Path' to '$Destination'"
}

function Unprotect-File {
    <#
    .SYNOPSIS
        Decrypts an Enkrypt v2 file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Destination
    )

    $Path = Resolve-Path $Path
    if (-not (Test-Path $Path)) { throw "File not found: $Path" }

    $fs = [System.IO.File]::OpenRead($Path)
    
    try {
        # 1. Read Header Length
        $LenBytes = New-Object byte[] 4
        $read = $fs.Read($LenBytes, 0, 4)
        if ($read -lt 4) { throw "Invalid file format (header missing)" }
        
        $HeaderLen = [BitConverter]::ToInt32($LenBytes, 0)
        if ($HeaderLen -gt 1024 * 1024) { throw "Header too large (corrupt file?)" }
        
        # 2. Read Header
        $HeaderBytes = New-Object byte[] $HeaderLen
        $read = $fs.Read($HeaderBytes, 0, $HeaderLen)
        if ($read -lt $HeaderLen) { throw "Invalid file format (truncated header)" }
        
        $HeaderJson = [System.Text.Encoding]::UTF8.GetString($HeaderBytes)
        $Header = $HeaderJson | ConvertFrom-Json
        
        if ($Header.format -ne "enkrypt") { throw "Unknown format: $($Header.format)" }
        
        # 3. Unwrap Key
        $WrappedKey = $Header.wrappedKey
        $DEK = Unprotect-EnkryptKey -WrappedKeyBase64 $WrappedKey
        
        # 4. Prepare Decryption
        $Nonce = [Convert]::FromBase64String($Header.iv)
        $Tag = [Convert]::FromBase64String($Header.authTag)
        
        # Read remaining stream as Ciphertext
        $CipherLen = $fs.Length - $fs.Position
        $CipherBytes = New-Object byte[] $CipherLen
        $read = $fs.Read($CipherBytes, 0, $CipherLen)
        
        $PlainBytes = New-Object byte[] $CipherLen
        
        # 5. Decrypt
        $AesGcm = New-Object System.Security.Cryptography.AesGcm($DEK, $Global:EnkryptConfig.TagSize)
        try {
            $AesGcm.Decrypt($Nonce, $CipherBytes, $Tag, $PlainBytes, $null)
        }
        catch {
            throw "Decryption failed. Integrity check failed or invalid key."
        }
        finally {
            $AesGcm.Dispose()
        }
        
        # 6. Write Output
        [System.IO.File]::WriteAllBytes($Destination, $PlainBytes)
        
        Write-Verbose "Decrypted '$Path' to '$Destination'"
    }
    finally {
        $fs.Dispose()
    }
}

Export-ModuleMember -Function Protect-File, Unprotect-File
