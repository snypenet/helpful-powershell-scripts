Param(
    [switch]
    $WhatIf
)

# This script will delete all local branches that are not in your remote.  Use at your own risk!!!

& git fetch -p | Out-Null
$remoteBranches = & git branch -r
$localBranches = & git branch


foreach($lb in $localBranches) {
    $lb = $lb.Replace("*", "").Trim()

    $found = $False
    foreach($rb in $remoteBranches) {
        if ($rb.Replace("origin/", "").Trim() -eq $lb) {
            $found = $True
        }
    }

    if (-Not $found) {
        Write-Host "Deleting $lb"
        if (-Not $WhatIf) {
            & git branch -D $lb
        } else {
            Write-Host "WhatIf is set.  $lb is NOT deleted"
        }
    }
}
