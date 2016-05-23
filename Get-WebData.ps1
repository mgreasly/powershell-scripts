[CmdletBinding()]            
Param(            
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][string]$url,
    [Switch]$useDefaultCredentials = $false
)
$value = New-Object System.Object
$value | Add-Member -MemberType:NoteProperty -Name:"Url" -Value:$url
$value | Add-Member -MemberType:NoteProperty -Name:"Code" -Value:0
$value | Add-Member -MemberType:NoteProperty -Name:"Description" -Value:""
try {
    $webRequest = [System.Net.WebRequest]::Create($url)
    $webRequest.UseDefaultCredentials = $useDefaultCredentials
    $webResponse = $webRequest.GetResponse()
    $value.Code = [int]$webResponse.StatusCode
    $value.Description = $webResponse.StatusDescription
} 
catch [System.Net.WebException]  {    
    $value.Code = [int]$_.Exception.Response.StatusCode
    $value.Description = $_.Exception.Response.StatusDescription
}
if ($webResponse) { $webResponse.Close() }
Write-Output $value
