# --------------------------------------
# Enkrypter
# --------------------------------------
Add-Type -AssemblyName System.Security

$InputFile = Join-Path $PSScriptRoot "..\test-file.md"
$OutputFile = Join-Path $PSScriptRoot "..\test-file.md.enkrypted"

if (-not (Test-Path $InputFile)) {
    throw "Input file not found: $InputFile"
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