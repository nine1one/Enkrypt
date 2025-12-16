# --------------------------------------
# Dekrypter V2 Wrapper
# --------------------------------------
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Path
)

# Import the core module
$ModulePath = Join-Path $PSScriptRoot "Enkrypt.psm1"
if (!(Get-Module Enkrypt)) {
    Import-Module $ModulePath -Force
}

$InputFile = Resolve-Path $Path
# Strip .enkrypted extension if present
if ($Path -match '\.enkrypted$') {
    $OutputFile = $Path -replace '\.enkrypted$', ''
}
else {
    $OutputFile = "$InputFile.decrypted"
}

if (-not (Test-Path $InputFile)) {
    throw "Input file not found: $InputFile"
}

Write-Host "Dekrypting '$InputFile'..." -ForegroundColor Cyan

try {
    Unprotect-File -Path $InputFile -Destination $OutputFile
    
    if (Test-Path $OutputFile) {
        Remove-Item $InputFile -Force
        Write-Host "Success: '$OutputFile' restored." -ForegroundColor Green
    }
}
catch {
    Write-Error "Decryption Failed: $_"
}
