Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Pop-Location

Set-PSDebug -Strict
$ErrorActionPreference = "stop"
