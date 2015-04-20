Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Import-Module PsGet
Import-Module PsUrl
Import-Module PsColor
Import-Module posh-hg
Import-Module posh-git

$VIMPATH    = "C:\Program Files (x86)\Vim\vim74\gvim.exe"

Set-Alias -Name ll -Value Get-ChildItem -Description "own: Get-ChildItem"
Set-Alias -Name vi -Value $VIMPATH
Set-Alias -Name vim -Value $VIMPATH

# Show all available aliase
function Show-Alias() {
	Get-Help * | ?{$_.Category -eq "Alias"} | sort Name | Format-Table -auto
}

# Show all available contextual help
function Show-About() {
	Get-Help About_ | select name,synopsis | format-table -auto
}

# Get the IP adresses
function Get-Ips() {
   $ent = [net.dns]::GetHostEntry([net.dns]::GetHostName())
   return $ent.AddressList | ?{ $_.ScopeId -ne 0 } | %{
      [string]$_
   }
}

# Edit the hosts file
function Edit-HostsFile() {
   param($ComputerName=$env:COMPUTERNAME)
    Start-Process notepad.exe -ArgumentList \\$ComputerName\admin$\System32\drivers\etc\hosts -Verb RunAs
}

# Launch explorer in current folder
function e() {
    ii .
}

# Remove temporary files
function Remove-TempFiles() {
	Get-ChildItem . -include *.bak, *.orig, thumbs.db, Thumbs.db -recurse | foreach ($_) { remove-item $_.fullname }
}

# Check if user is administrator
function Get-IsAdminUser() {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $wp = new-object Security.Principal.WindowsPrincipal($id)
    
    return $wp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function df ( $Path ) {
	if ( !$Path ) { $Path = (Get-Location -PSProvider FileSystem).ProviderPath }
	$Drive = (Get-Item $Path).Root -replace "\\"
	$Output = Get-WmiObject -Query "select freespace from win32_logicaldisk where deviceid = `'$drive`'"
	Write-Output "$($Output.FreeSpace / 1mb) MB"
}

function Resolve-IPAddress 
{    
    param ( [IPAddress] $IPAddress )

    [Net.DNS]::GetHostByAddress($IPAddress)
} 

# pull and update all Mercurial repositoriesin the current directory
function hg-all()
{
	$s = New-Object PSObject -Property @{
	    FolderForegroundColor = [ConsoleColor]::Cyan
    }

	Get-ChildItem -r -i .hg -fo | % {
		Push-Location $_.fullname
		cd ..
		Write-Host -fore $s.FolderForegroundColor (Get-Location).Path
		hg pull -u
		Pop-Location
	}
}
 
$global:HgPromptSettings.BeforeText = ' hg ['
$global:GitPromptSettings.BeforeText = ' git ['
$global:PSColor.File.Code.Pattern = '\.(java|c|cpp|cs|js|css|html|scss|json|aspx)$'
$global:PSColor.File.Text.Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown|config)$'
$global:PSColor.File.Compressed.Pattern = '\.(zip|tar|gz|rar|jar|war)$'

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

#Enable-GitColors

Pop-Location

#Start-SshAgent -Quiet
