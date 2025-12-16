# --------------------------------------
# Enkrypter
# --------------------------------------
Add-Type -AssemblyName System.Security

$InputFile = Join-Path $PSScriptRoot "..\test-file.md"
$OutputFile = Join-Path $PSScriptRoot "..\test-file.md.enkrypted"

if (-not (Test-Path $InputFile)) {
    throw "Input file not found: $InputFile"
}

# Check if file is likely already encrypted (binary check)
# We assume text files (Markdown) won't have null bytes in the first 1KB.
try {
    $Stream = [System.IO.File]::OpenRead($InputFile)
    $HeaderBuffer = New-Object byte[] 1024
    $ReadCount = $Stream.Read($HeaderBuffer, 0, 1024)
}
finally {
    if ($Stream) { $Stream.Dispose() }
}

if ($ReadCount -gt 0 -and ($HeaderBuffer[0..($ReadCount-1)] -contains 0)) {
    Write-Warning "Skipping execution: '$InputFile' appears to be binary or already encrypted."
    exit
}

$PlainBytes = [System.IO.File]::ReadAllBytes($InputFile)

$ProtectedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
    $PlainBytes,
    $null,
    [System.Security.Cryptography.DataProtectionScope]::CurrentUser
)

[System.IO.File]::WriteAllBytes($OutputFile, $ProtectedBytes)

if (Test-Path $OutputFile) {
    Remove-Item $InputFile -Force
    Move-Item -Path $OutputFile -Destination $InputFile -Force
}
else {
    Write-Error "Encryption failed: Output file not created. Original file preserved."
}
# --------------------------------------


# # --------------------------------------
# # Dekrypter
# # --------------------------------------
# Add-Type -AssemblyName System.Security

# $InputFile = Join-Path $PSScriptRoot "..\test-file.md"
# $OutputFile = Join-Path $PSScriptRoot "..\test-file.md.decrypted"

# if (-not (Test-Path $InputFile)) {
#     throw "Input file not found: $InputFile"
# }

# $EncryptedBytes = [System.IO.File]::ReadAllBytes($InputFile)

# try {
#     $PlainBytes = [System.Security.Cryptography.ProtectedData]::Unprotect(
#         $EncryptedBytes,
#         $null,
#         [System.Security.Cryptography.DataProtectionScope]::CurrentUser
#     )

#     [System.IO.File]::WriteAllBytes($OutputFile, $PlainBytes)

#     if (Test-Path $OutputFile) {
#         Remove-Item $InputFile -Force
#         Move-Item -Path $OutputFile -Destination $InputFile -Force
#     }
#     else {
#         Write-Error "Decryption failed: Output file not created."
#     }
# }
# catch {
#     Write-Error "Decryption failed: $_"
#     if (Test-Path $OutputFile) { Remove-Item $OutputFile -Force }
# }
# # --------------------------------------