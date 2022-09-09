Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Staging", "Production")]
    [string]
    $Environment
)

$stagingStorageAccount = "<azure staging storage account name>"
$prodStorageAccount = "<azure prod storage account name>"

if (-Not (Test-Path "$PSScriptRoot/.terraform/terraform.tfstate")) {
    Write-Warning "Local Terraform state Reference is missing.  Expected it to be at: $PSScriptRoot/.terraform/terraform.tfstate"
    return $False;
}

try {
    $stateFile = (Get-Content "$PSScriptRoot/.terraform/terraform.tfstate") -Join ""

    $state = ConvertFrom-Json $stateFile
    if ($null -eq $state.backend -or $null -eq $state.backend.config) {
        Write-Warning "No storage account found in local state. Unable to verify."
        return $False
    }

    if ($Environment -eq "Staging") {
        $expected = $stagingStorageAccount
    } else {
        $expected = $prodStorageAccount
    }
    
    $result = $state.backend.config.storage_account_name -eq $expected
    if (-Not $result) {
        Write-Warning "Expected storage account to be '$expected' found '$($state.backend.config.storage_account_name)' instead"
    }

    return $result
} catch {
    Write-Error $_
    return $False
}
