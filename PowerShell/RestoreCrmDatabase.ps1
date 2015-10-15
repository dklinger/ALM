param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$sqlName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$dbname,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$backupFileName
)

# Set SQL Server instance name
#$sqlName= "VSDEV-SQL2012-1\MSCRMVOGEL2015"

# Set new or existing databse name to restote backup
#$dbname= "master_MSCRM"

# Set the existing backup file path
#$backupPath= "\\sgc-ls.gcn.lan\Freigabe\DK\ALM\develop.bak"

#Load the required assemlies SMO and SmoExtended.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null 

# Connect SQL Server.
$sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $sqlName

$sqlServer.ConnectionContext.LoginSecure = $false 
$credential = get-Credential 
$sqlServer.ConnectionContext.Login=$credential.UserName 
$sqlServer.ConnectionContext.set_SecurePassword($credential.Password) 

# Get Instance backup directory
$backupPath= $sqlServer.BackupDirectory + "\" + $backupFileName
Write-Host "backup file path:"$backupPath

# Create SMo Restore object instance
$dbRestore = new-object ("Microsoft.SqlServer.Management.Smo.Restore")

# Set database and backup file path
$dbRestore.Database = $dbname
$dbRestore.Devices.AddDevice($backupPath, "File")

# Set the databse file location
$dbRestoreFile = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
$dbRestoreLog = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
$dbRestoreFile.LogicalFileName = "mscrm"
$dbRestoreFile.PhysicalFileName = $sqlServer.Information.MasterDBPath + "\" + $dbRestore.Database + "_Data.mdf"
$dbRestoreLog.LogicalFileName = "mscrm" + "_Log"
$dbRestoreLog.PhysicalFileName = $sqlServer.Information.MasterDBLogPath + "\" + $dbRestore.Database + "_Log.ldf"
$dbRestore.RelocateFiles.Add($dbRestoreFile)
$dbRestore.RelocateFiles.Add($dbRestoreLog)

# Call the SqlRestore mathod to complete restore database 
try
{
    $dbRestore.SqlRestore($sqlServer)
    Write-Host "...SQL Database"$dbname" Restored Successfully..."
}
catch 
{
    Write-Host $_.Exception.InnerException.InnerException.InnerException.Message
    Write-Host $_.Exception.StackTrace
}