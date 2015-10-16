param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$newOrgName
)

.\CheckAndInstallRequirements.ps1

$dbName = $newOrgName + "_MSCRM"

$secpasswd = ConvertTo-SecureString "Ts08mX#" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("dev\administrator", $secpasswd)

if (-not (Get-PSSnapin -Name Microsoft.Xrm.Tooling.Connector -ErrorAction SilentlyContinue))
{
    Add-PSSnapin Microsoft.Xrm.Tooling.Connector
    $RemoveSnapInWhenDone = $True
}

$backup = $false;
$restore = $false;
$import = $false;

try
{
    $conn = Get-CrmConnection -InteractiveMode
    $uri = ([System.Uri]$conn.ConnectedOrgPublishedEndpoints["WebApplication"])
    $serverUrl = $uri.Scheme + "://" + $uri.DnsSafeHost

    $orgSqlInstanceAndDbName = .\GetOrganizationDetailsFromDeploymentServer.ps1 $serverUrl $conn.ConnectedOrgUniqueName $cred
    
    $sqlInstsance = $orgSqlInstanceAndDbName[0]
    $orgname = $orgSqlInstanceAndDbName[1]
    $srsUrl = $orgSqlInstanceAndDbName[2]


    $backup = .\BackupDatabase.ps1 $sqlInstsance $orgname ($orgname + "_" + [system.environment]::MachineName + ".bak")
    
    $restore = .\RestoreCrmDatabase.ps1 $sqlInstsance $dbName ($orgname + "_" + [system.environment]::MachineName + ".bak")
    
    $import = .\ImportOrg.ps1 $sqlInstsance $dbName $srsUrl $newOrgName $serverUrl vsdev-vogel2015.dev.gc $cred
    
}
catch
{
    
    Write-Host $_.Exception
    if($restore -eq $true -and $import -eq $false)
    {
        Write-Host "Delete Restored DB"
        #TODO: Delete Restored DB
    }
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
        Write-Host "Org successfully copied:"$server"/"$orgname" =>"$server"/"$newOrgName
        Start-Process -FilePath ($server + "/" + $newOrgName)
    }
}
if($RemoveSnapInWhenDone)
{
    Remove-PSSnapin Microsoft.Xrm.Tooling.Connector
}