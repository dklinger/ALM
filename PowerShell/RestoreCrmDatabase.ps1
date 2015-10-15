param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$sqlName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$dbname,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$backupFileName
)

Function Restore([bool]$askForCredentials)
{
    #Load the required assemlies SMO and SmoExtended.
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null 

    # Connect SQL Server.
    $sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $sqlName

    if($askForCredentials)
    {
        $credential = get-Credential 
        $sqlServer.ConnectionContext.LoginSecure = $false 
        $sqlServer.ConnectionContext.Login=$credential.UserName 
        $sqlServer.ConnectionContext.set_SecurePassword($credential.Password) 
    }
    else
    {
        $sqlServer.ConnectionContext.LoginSecure = $false 
        $sqlServer.ConnectionContext.Login = "sa"
        $sqlServer.ConnectionContext.Password = "Ts08mX#"
    }

    # Get Instance backup directory
    $backupPath= $sqlServer.BackupDirectory + "\" + $backupFileName
    Write-Host "backup file path:"$backupPath

    # Create SMo Restore object instance
    $dbRestore = new-object ("Microsoft.SqlServer.Management.Smo.Restore")

    # Set database and backup file path
    $dbRestore.Database = $dbname
    $dbRestore.Devices.AddDevice($backupPath, "File")

    #Get Default Paths for Data- and Log-Files
    $dataLoc = $sqlServer.Settings.DefaultFile
	$logLoc = $sqlServer.Settings.DefaultLog
	if ($dataLoc.Length -eq 0) 
    {
	    $dataLoc = $sqlServer.Information.MasterDBPath
    }
	if ($logLoc.Length -eq 0) 
    {
        $logLoc = $sqlServer.Information.MasterDBLogPath
	}

    # Set the databse file location
    $dbRestoreFile = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
    $dbRestoreLog = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
    $dbRestoreFile.LogicalFileName = "mscrm"
    $dbRestoreFile.PhysicalFileName = $dataLoc + "\" + $dbRestore.Database + ".mdf"
    $dbRestoreLog.LogicalFileName = "mscrm" + "_Log"
    $dbRestoreLog.PhysicalFileName = $logLoc + "\" + $dbRestore.Database + ".ldf"
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
        if($_.Exception.InnerException -match "Login failed")
        {
            Write-Host "Login failed. Retrying asking for credentials."
            return $false
        }
        else
        {
            Write-Host $_.Exception.InnerException.Message
            Write-Host $_.Exception.InnerException;
            throw 
        }
    }

    return $true
}

if (Get-Module -ListAvailable -Name sqlps) {
    $loginSuccessful = Restore
    while($loginSuccessful -eq $false)
    {
        $loginSuccessful = Restore $true
    }
} else {
    throw "Module sqlps is not installed."
}

return $loginSuccessful