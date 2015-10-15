param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$FeatureName
)

try
{
    $FeatureName = $FeatureName -creplace '[^a-zA-Z0-9\-]', ''
    $FeatureName = $FeatureName -replace '(.{30}).+','$1'

    cd C:\Arbeit\Git-Repos\Heraeus_MSCRM

    git flow feature start $FeatureName

    cd C:\GC\DeveloperTools\SyncToClients\ALM\PowerShell
    .\CreateNewOrgFromExistingOrg.ps1 $FeatureName
}
catch
{
    throw
}