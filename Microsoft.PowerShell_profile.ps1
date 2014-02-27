Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# use this instead (see about_Modules for more information):
Import-Module posh-git
Import-Module posh-hg

Pop-Location

# debugging parameters
Set-PSDebug -Strict
$ErrorActionPreference = "stop"

$powershellPath = [Environment]::GetFolderPath("Personal") + "/WindowsPowershell"

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

function Get-Ips() {
   $ent = [net.dns]::GetHostEntry([net.dns]::GetHostName())
   return $ent.AddressList | ?{ $_.ScopeId -ne 0 } | %{
      [string]$_
   }
}

function UrlDecode([string]$url) {
    [Web.HttpUtility]::UrlDecode($url)
}

function UrlEncode([string]$url) {
    [Web.HttpUtility]::UrlEncode($url)
}

function HtmlDecode([string]$url) {
    [Web.HttpUtility]::HtmlDecode($url)
}

function HtmlEncode([string]$url) {
    [Web.HttpUtility]::HtmlEncode($url)
}

# Launch explorer in current folder
function e {
    ii .
}

# posh-git settings
$global:GitPromptSettings.BeforeText = ' git ['
$global:GitPromptSettings.UntrackedText = ' ?'
$global:GitPromptSettings.UntrackedForegroundColor = [ConsoleColor]::Red
$global:GitPromptSettings.Debug = $true

# posh-hg settings
$global:HgPromptSettings.BeforeText = ' hg ['
$global:HgPromptSettings.ModifiedForegroundColor = [ConsoleColor]::Yellow
$global:HgPromptSettings.DeletedForegroundColor = [ConsoleColor]::Cyan
$global:HgPromptSettings.UntrackedForegroundColor = [ConsoleColor]::Red
$global:HgPromptSettings.MissingForegroundColor = [ConsoleColor]::Magenta
$global:HgPromptSettings.RenamedForegroundColor = [ConsoleColor]::Blue

function prompt { 
    $Host.UI.RawUI.WindowTitle = $env:username + '@' + [System.Environment]::MachineName + ' - ' + $pwd 
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE

    return '> ' 
} 

Enable-GitColors

Pop-Location
