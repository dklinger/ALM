param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$pathOfLocalFiles,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$filterCondition,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$networkShare,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$networkShareUsername,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$networkSharePassword,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$driveLetter,
        [Parameter(Mandatory=$false,ValueFromPipeline=$True)]
        [string]$networkShareFolder,
        [Parameter(Mandatory=$false,ValueFromPipeline=$True)]
        [switch]$disconnectNetworkDrive
)

$net = New-Object -com WScript.Network
$drive = $driveLetter + ":"

if (-Not(test-path $drive)) 
{ 
    $net.mapnetworkdrive($drive, $networkShare, $false, $networkShareUsername, $networkSharePassword) 
}

Get-ChildItem �path $pathOfLocalFiles -Recurse -Filter $filterCondition | 
Foreach-Object  { copy-item -Path $_.fullname -Destination $networkShare$networkShareFolder }

if($disconnectNetworkDrive)
{
    $net.RemoveNetworkDrive($drive, 1, 1) 
}