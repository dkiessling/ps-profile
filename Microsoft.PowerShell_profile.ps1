Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Pop-Location

# debugging parameters
Set-PSDebug -Strict
$ErrorActionPreference = "stop"

$powershellPath = [Environment]::GetFolderPath("Personal") + "/WindowsPowershell"

Set-Alias fortune "$powershellPath/fortune.ps1"
Remove-Item alias:ls
Set-Alias ls Get-ChildItemColor
Set-Alias ll Get-ChildItemColor

function Get-ChildItemColor {
    $fore = $Host.UI.RawUI.ForegroundColor

    Invoke-Expression ("Get-ChildItem $args") |
    %{
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $Host.UI.RawUI.ForegroundColor = 'White'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($_.Name -match '\.(zip|tar|gz|rar)$') {
            $Host.UI.RawUI.ForegroundColor = 'Blue'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($_.Name -match '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$') {
            $Host.UI.RawUI.ForegroundColor = 'Green'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($_.Name -match '\.(txt|cfg|conf|ini|csv|sql|xml|config)$') {
            $Host.UI.RawUI.ForegroundColor = 'Cyan'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($_.Name -match '\.(cs|asax|aspx.cs)$') {
            $Host.UI.RawUI.ForegroundColor = 'Yellow'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($_.Name -match '\.(aspx|spark|master)$') {
            $Host.UI.RawUI.ForegroundColor = 'DarkYellow'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($_.Name -match '\.(sln|csproj)$') {
            $Host.UI.RawUI.ForegroundColor = 'Magenta'
            echo $_
            $Host.UI.RawUI.ForegroundColor = $fore
        }
        else {
            $Host.UI.RawUI.ForegroundColor = $fore
            echo $_
        }
    }
}

function Get-Adminuser() {
   $id = [Security.Principal.WindowsIdentity]::GetCurrent()
   $p = New-Object Security.Principal.WindowsPrincipal($id)
   return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-AdminBackground() {
    if ( Get-Adminuser ) {
        $chost = [ConsoleColor]::DarkRed;
    } else {
        $chost = $Host.UI.RawUI.BackgroundColor
    }

    $Host.UI.RawUI.BackgroundColor = $chost
}

function get-ips() {
   $ent = [net.dns]::GetHostEntry([net.dns]::GetHostName())
   return $ent.AddressList | ?{ $_.ScopeId -ne 0 } | %{
      [string]$_
   }
}

Set-AdminBackground
fortune
