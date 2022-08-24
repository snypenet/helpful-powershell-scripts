# This script will delete all local branches that are not in your remote.  Use at your own risk!!!

& git fetch -p | Out-Null
$remoteBranches = & git branch -r
$localBranches = & git branch


foreach($lb in $localBranches) {
    $lb = $lb.Trim()

    $found = $False
    foreach($rb in $remoteBranches) {
        if ($rb.Replace("origin/", "").Trim() -eq $lb) {
            $found = $True
        }
    }

    if (-Not $found) {
        Write-Host "Deleting $lb"
        & git branch -D $lb
    }
}
