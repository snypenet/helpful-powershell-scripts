Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Staging", "Production")]
    [string]
    $Environment
)

$stagingTenantId = "<staging tenant id>"
$prodTenantId = "<prod tenant id>"

try{
    $accountInformation = (& az account show) -Join ""
    if ($Environment -eq "Staging") {
        $expectedTenant = $stagingTenantId
    } elseif($Environment -eq "Production") {
        $expectedTenant = $prodTenantId
    }

    if ($null -eq $expectedTenant) {
        Write-Warning "$Environment is an unknown environment"
        return $False
    }

    $result = $accountInformation.Contains($expectedTenant)
    if (-Not $result) {
        Write-Warning "Expected to be signed into Tenant $expectedTenant"
    }

    return $result
}catch{
    Write-Error $_
    return $False
}
