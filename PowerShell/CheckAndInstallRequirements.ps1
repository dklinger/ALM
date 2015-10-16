
if (-not (Get-PSSnapin -Name Microsoft.Xrm.Tooling.Connector -Registered -ErrorAction SilentlyContinue))
{
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {   
        #"No Administrative rights, it will display a popup window asking user for Admin rights"
        $arguments = "& cd $pwd\Requirements\sdk-bin;.\RegisterXRMTooling.ps1;"
        $arguments
        Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments -Wait
    }
}

if (-Not(Get-Module -ListAvailable -Name sqlps)) {
        Start-Process "$pwd\Requirements\dacframework.msi" -Wait
        Start-Process "$pwd\Requirements\SharedManagementObjects.msi" -Wait
        Start-Process "$pwd\Requirements\PowerShellTools.msi" -Wait
}
