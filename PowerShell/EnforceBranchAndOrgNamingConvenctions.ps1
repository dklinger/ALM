param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
    [string]$orgOrBranchName
)

$orgOrBranchName = $orgOrBranchName -creplace '[^a-zA-Z0-9\-]', ''
$orgOrBranchName = $orgOrBranchName -replace '(.{30}).+','$1'

return $orgOrBranchName