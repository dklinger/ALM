param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$serverUrl,
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$orgUniqueName,
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [PSCredential]$cred
)

$session = New-PSSession -credential $cred -ComputerName vsdev-vogel2015.dev.gc
$result = Invoke-Command -session $session -ScriptBlock { 
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$serverUrl,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$orgUniqueName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [PSCredential]$cred
    )

    if (-not (Get-PSSnapin -Name Microsoft.Crm.PowerShell -ErrorAction SilentlyContinue))
    {
        Add-PSSnapin Microsoft.Crm.PowerShell
        $RemoveSnapInWhenDone = $True
    }

    $orgs = Get-CrmOrganization -Name $orgUniqueName -DwsServerUrl $serverUrl -Credential $cred
    $result = @($orgs[0].SqlServerName, $orgs[0].DatabaseName, $orgs[0].SrsUrl)

    if($RemoveSnapInWhenDone)
    {
        #Remove-PSSnapin Microsoft.Crm.PowerShell
    }

    return $result
} -ArgumentList $serverUrl, $orgUniqueName, $cred

Remove-PSSession -Id $session.Id

$result