if (-Not(Get-Module -ListAvailable -Name WebAdministration)) {
	return;
}

$appPoolUser = "dev\_svc-almCrmDeploy";
$appPoolUserPw = "nmidopf";

Import-Module WebAdministration;

try {
    $deploymentAppPool = Get-ItemProperty iis:\apppools\CrmDeploymentServiceAppPool -Name processModel;
    
}
catch {
    return;
}

if(-Not($deploymentAppPool.userName -eq $appPoolUser)){
	Set-ItemProperty iis:\apppools\CrmDeploymentServiceAppPool -name processModel -value @{userName=$appPoolUser;password=$appPoolUserPw;identitytype=3};
}