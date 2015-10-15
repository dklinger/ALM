param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$sqlName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$dbname,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$backupFileName
)

Function Backup([bool]$askForCredentials)
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
    $dbBackup = new-object ("Microsoft.SqlServer.Management.Smo.Backup")

    # Set database and backup file path
    $dbBackup.Database = $dbname
    $dbBackup.Devices.AddDevice($backupPath, "File")

    # Set the databse file location
    $dbBackup.Action = 'Database'
    $dbBackup.BackupSetName = $dbname + " Backup"
    $dbBackup.MediaDescription = "Disk"
    $dbBackup.CompressionOption = 1
    $dbBackup.Initialize = $true
    
    # Call the SqlRestore mathod to complete restore database 
    try
    {
        $dbBackup.SqlBackup($sqlServer)
        Write-Host "...SQL Database"$dbname" Backup Successfully..."
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
    $loginSuccessful = Backup
    while($loginSuccessful -eq $false)
    {
        $loginSuccessful = Backup $true
    }
} else {
    throw "Module sqlps is not installed."
}

return $loginSuccessful