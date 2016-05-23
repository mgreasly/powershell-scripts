[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]$Path
)

$folder = Get-Item $Path
$ddfFileName = "{0}.ddf" -f $folder.name

$ddfHeaderText = (@"
;*** MakeCAB Directive file
;
.OPTION EXPLICIT
.set CabinetName1={0}
.set DiskDirectory1={1}
.Set MaxDiskSize=CDROM
.Set Cabinet=on
.Set Compress=on
"@ -f ("{0}.cab" -f $folder.name), $folder.Parent.FullName)
$ddfHeaderText | Out-File -FilePath:$ddfFileName -Encoding:ASCII -Force

dir $Path -Recurse | ? { !$_.psiscontainer } | % {
    $file = $_
    $path = $file.FullName.Replace($folder.FullName, "").Replace($file.Name, "").Trim("\")
    if ($path.Length -gt 0) { (".set DestinationDir={0}") -f $path | Out-File -FilePath:$ddfFileName -Encoding:ASCII -Append }
    ("'{0}'" -f $file.FullName) | Out-File -FilePath:$ddfFileName -Encoding:ASCII -Append
}

makecab /F $ddfFileName /V1

$ddfFileName, "setup.inf", "setup.rpt" | Remove-Item