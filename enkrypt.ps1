# --------------------------------------
# Enkrypter V2 Wrapper
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
$OutputFile = "$InputFile.enkrypted"

if (-not (Test-Path $InputFile)) {
    throw "Input file not found: $InputFile"
}

Write-Host "Enkrypting '$InputFile'..." -ForegroundColor Cyan

try {
    Protect-File -Path $InputFile -Destination $OutputFile
    
    if (Test-Path $OutputFile) {
        Remove-Item $InputFile -Force
        Write-Host "Success: '$OutputFile' created." -ForegroundColor Green
    }
}
catch {
    Write-Error "Encryption Failed: $_"
}
