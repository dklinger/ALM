param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$serverUrl,
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$FeatureName
)

try
{
    $FeatureName = .\EnforceBranchAndOrgNamingConvenctions.ps1 $FeatureName
    
    $exists = git show-ref --verify refs/heads/feature/$FeatureName
    if($exists -eq $null)
    {
        git flow feature start feature/$FeatureName
    }
    else
    {
        git checkout feature/$FeatureName
    }

    cd C:\GC\DeveloperTools\SyncToClients\ALM\PowerShell
    .\CreateNewOrgFromExistingOrg.ps1 $serverUrl $FeatureName "develop"
}
catch
{
    throw
}