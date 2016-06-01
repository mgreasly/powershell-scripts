[CmdletBinding()]            
Param(            
	[Parameter(Mandatory=$true)][string]$WebUrl,
	[Parameter(Mandatory=$true)][string]$ListName,
	[Parameter()][string]$OutputFolder = $PSScriptRoot
)

Add-PsSnapin Microsoft.SharePoint.PowerShell
Set-Location $PSScriptRoot

function Write-Command($msg) { Write-Host ("{0, -100} ... " -f $msg) -NoNewline }

function Process-File($file, $root) {
    Write-Command ("Export '{0}'" -f $file.Name)
    $path = $file.ServerRelativeUrl.Replace($file.ParentFolder.ParentWeb.ServerRelativeUrl, "").Trim("/")
    $path = "{0}\{1}" -f $root, $path
    $byteArray = $file.OpenBinary()
    $fileStream = New-Object System.IO.FileStream($path, [System.Io.FileMode]::Create)
    $binaryWriter = New-Object System.IO.BinaryWriter($fileStream)
    $binaryWriter.Write($byteArray)
    $binaryWriter.Close()
    $fileStream.Close()
    Write-Host "Ok" -ForegroundColor:Green
}

function Process-Folder($folder, $root) {
    $path = $folder.ServerRelativeUrl.Replace($folder.ParentWeb.ServerRelativeUrl, "").Trim("/")
    $path = "{0}\{1}" -f $root, $path
    if (!(Test-Path $path)) { 
        Write-Command ("Create '{0}' folder" -f $folder.Name)
        $f = mkdir $path
        Write-Host "Ok" -ForegroundColor:Green
    }
    $folder.Files | % { Process-File $_ $root }
    $folder.SubFolders | % { Process-Folder $_ $root }
}


Write-Command ("Open site at {0}" -f $WebUrl)
$web = Get-SPWeb $WebUrl
Write-Host "Ok" -ForegroundColor:Green

Write-Command ("Access '{0}'" -f $ListName)
$list = $web.Lists[$ListName]
Write-Host "Ok" -ForegroundColor:Green

Process-Folder $list.RootFolder $OutputFolder