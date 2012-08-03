Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Pop-Location

Set-PSDebug -Strict
$ErrorActionPreference = "stop"

$powershellPath = [Environment]::GetFolderPath("Personal") + "/WindowsPowershell"

Set-Alias fortune "$powershellPath/fortune.ps1"
fortune
