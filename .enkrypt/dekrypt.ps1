# # --------------------------------------
# # Enkrypter
# # --------------------------------------
# Add-Type -AssemblyName System.Security

# $InputFile  = Join-Path $PSScriptRoot "..\test-file.md"
# $OutputFile = Join-Path $PSScriptRoot "..\test-file.md.enkrypted"

# if (-not (Test-Path $InputFile)) {
#     throw "Input file not found: $InputFile"
# }

# $PlainBytes = [System.IO.File]::ReadAllBytes($InputFile)

# $ProtectedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
#     $PlainBytes,
#     $null,
#     [System.Security.Cryptography.DataProtectionScope]::CurrentUser
# )

# [System.IO.File]::WriteAllBytes($OutputFile, $ProtectedBytes)
# # --------------------------------------


# --------------------------------------
# Dekrypter
# --------------------------------------
Add-Type -AssemblyName System.Security

$InputFile  = Join-Path $PSScriptRoot "..\test-file.md.enkrypted"
$OutputFile = Join-Path $PSScriptRoot "..\test-file.md"

if (-not (Test-Path $InputFile)) {
    throw "Input file not found: $InputFile"
}

$EncryptedBytes = [System.IO.File]::ReadAllBytes($InputFile)

$PlainBytes = [System.Security.Cryptography.ProtectedData]::Unprotect(
    $EncryptedBytes,
    $null,
    [System.Security.Cryptography.DataProtectionScope]::CurrentUser
)

[System.IO.File]::WriteAllBytes($OutputFile, $PlainBytes)
# --------------------------------------


# # --------------------------------------
# # I want to encrypt the text inside of the registry file "TPAI_HKCU_HKLM.reg". And i want to do this by creating a simple scripting for myself which will be my own, correct?
# # - I am calling it as enkrypt

# ```powershell
#  ls -r

#     Directory: C:\.nmh\SideBAR\Registry-Keys

# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# d----          12/14/2025  8:32 PM                .enkrypt

# -a---          12/14/2025  8:27 PM          57556 TPAI_HKCU_HKLM.reg

#     Directory: C:\.nmh\SideBAR\Registry-Keys\.encrypter

# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# -a---          12/14/2025  8:32 PM            178 enkrypt-it.ps1
# ```

# ```#enkrypt-it.ps1
# # Write encryption logic code here

# ## set '../' as the current working directory and this file is being located at 
# ### root
# ### - .enkrypt/
# ### -- enkrypt-it.ps1
# ###
# ```
# # --------------------------------------
