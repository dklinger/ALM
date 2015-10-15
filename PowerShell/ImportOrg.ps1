param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$sqlName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$dbname,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$srsUrl,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$orgName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$serverUrl,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$almServer,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [PSCredential]$cred
)

$session = New-PSSession -credential $cred -ComputerName $almServer
$result = Invoke-Command -session $session -ScriptBlock { 
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$sqlName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$dbname,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$srsUrl,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$orgName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$serverUrl,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [PSCredential]$cred
    )

    if (-not (Get-PSSnapin -Name Microsoft.Crm.PowerShell -ErrorAction SilentlyContinue))
    {
        Add-PSSnapin Microsoft.Crm.PowerShell
        $RemoveSnapInWhenDone = $True
    }

    Import-CrmOrganization $sqlName $dbname $srsUrl $displayName $orgName "KeepExisting" -Credential $cred -DwsServerUrl $serverUrl

    if($RemoveSnapInWhenDone)
    {
        Remove-PSSnapin Microsoft.Crm.PowerShell
    }
} -ArgumentList $sqlName, $dbname, $srsUrl, $orgName, $serverUrl, $cred

Remove-PSSession -Id $session.Id

return $true