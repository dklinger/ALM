param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$serverUrl,
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$newOrgName,    
    [Parameter(Mandatory=$false,ValueFromPipeline=$True)]
    [string]$baseOrgName
)

try
{
    $almServer = "vsdev-vogel2015.dev.gc"

    .\CheckAndInstallRequirements.ps1
    $newOrgName = .\EnforceBranchAndOrgNamingConvenctions.ps1 $newOrgName

    $dbName = $newOrgName + "_MSCRM"

    $secpasswd = ConvertTo-SecureString "nmidopf" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("dev\_svc-almCrmDeploy", $secpasswd)

    if (-not (Get-PSSnapin -Name Microsoft.Xrm.Tooling.Connector -ErrorAction SilentlyContinue))
    {
        Add-PSSnapin Microsoft.Xrm.Tooling.Connector
        $RemoveSnapInWhenDone = $True
    }

    $backup = $false;
    $restore = $false;
    $import = $false;

    #$conn = Get-CrmConnection -InteractiveMode
    #$conn.ConnectedOrgPublishedEndpoints["WebApplication"]
    #$uri = ([System.Uri]$conn.ConnectedOrgPublishedEndpoints["WebApplication"])
    #$serverUrl = $uri.Scheme + "://" + $uri.DnsSafeHost

    $orgSqlInstanceAndDbName = .\GetOrganizationDetailsFromDeploymentServer.ps1 $serverUrl $baseOrgName $almServer $cred
    $orgSqlInstanceAndDbName
    $sqlInstance = $orgSqlInstanceAndDbName[0]
    $orgname = $orgSqlInstanceAndDbName[1]
    $srsUrl = $orgSqlInstanceAndDbName[2]


    $backup = .\BackupDatabase.ps1 $sqlInstance $orgname ($orgname + "_" + [system.environment]::MachineName + ".bak")
    
    $restore = .\RestoreCrmDatabase.ps1 $sqlInstance $dbName ($orgname + "_" + [system.environment]::MachineName + ".bak")
    
    $import = .\ImportOrg.ps1 $sqlInstance $dbName $srsUrl $newOrgName $serverUrl $almServer $cred
    
}
catch
{
    
    Write-Host $_.Exception
    if($restore -eq $true -and $import -eq $false)
    {
        Write-Host "Delete Restored DB"
        #TODO: Delete Restored DB
    }
    Read-Host -Prompt "Press Enter to exit"
}
finally
{
    if($restore -eq $true)
    {
        Write-Host "Delete backup-file"
        #TODO: Delete backup-file
    }
    
    if($backup -eq $true -and $restore -eq $true -and $import -eq $true)
    {
        Start-Sleep -s 5
        Write-Host "Waiting for Organization activation..."
        $newOrgDetails = .\GetOrganizationDetailsFromDeploymentServer.ps1 $serverUrl $newOrgName $almServer $cred
        while(-Not($newOrgDetails[3].ToString() -eq "Enabled"))
        {
            Write-Host "Checked State. State is:"$newOrgDetails[3]
            Start-Sleep -s 3
            $newOrgDetails = .\GetOrganizationDetailsFromDeploymentServer.ps1 $serverUrl $newOrgName $almServer $cred
        }
        Write-Host "Org successfully copied:"$serverUrl"/"$orgname" =>"$serverUrl"/"$newOrgName
        Start-Process -FilePath ($serverUrl + "/" + $newOrgName)
    }

    if($RemoveSnapInWhenDone)
    {
        Remove-PSSnapin Microsoft.Xrm.Tooling.Connector
    }
}