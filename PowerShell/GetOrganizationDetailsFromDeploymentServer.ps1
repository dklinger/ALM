param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$serverUrl,
    [Parameter(Mandatory=$false,ValueFromPipeline=$True)]
    [string]$orgUniqueName,
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$almServer,
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [PSCredential]$cred
)

$session = New-PSSession -credential $cred -ComputerName $almServer -Authentication Negotiate
$result = Invoke-Command -session $session -ScriptBlock { 
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$serverUrl,
        [Parameter(Mandatory=$false,ValueFromPipeline=$True)]
        [string]$orgUniqueName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [PSCredential]$cred
    )

    if (-not (Get-PSSnapin -Name Microsoft.Crm.PowerShell -ErrorAction SilentlyContinue))
    {
        Add-PSSnapin Microsoft.Crm.PowerShell
        $RemoveSnapInWhenDone = $True
    }
    
    $orgs = Get-CrmOrganization -DwsServerUrl $serverUrl -Credential $cred
    
    $orgExists = $false;
    foreach ($org in $orgs)
    {
        if($org.UniqueName -eq $orgUniqueName)
        {
            $orgExists = $true
            $result = @($org.SqlServerName, $org.DatabaseName, $org.SrsUrl, $org.State.ToString())
        }
    }
    
    if($orgExists -eq $false)
    {        
        Write-Host "Organization $orgUniqueName not found."
        $i = 0;
        foreach ($org in $orgs)
        {
            Write-Host "[$i] "$org.UniqueName
            $i++;
        }

        $i = Read-Host -Prompt "Choose base org";
        $result = @($orgs[$i].SqlServerName, $orgs[$i].DatabaseName, $orgs[$i].SrsUrl, $orgs[$i].State.ToString())
    }

    if($RemoveSnapInWhenDone)
    {
        Remove-PSSnapin Microsoft.Crm.PowerShell
    }

    return $result
} -ArgumentList $serverUrl, $orgUniqueName, $cred

Remove-PSSession -Id $session.Id

return $result