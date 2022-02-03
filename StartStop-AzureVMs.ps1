Param(
 [Parameter(Mandatory=$true)]
 [string]$resourceGroupName,
 [Parameter(Mandatory=$true)]
 [ValidateSet("Start", "Stop")]
 [string]
 $state
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

# Connect using a Managed Service Identity
try {
    $AzureContext = (Connect-AzAccount -Identity).context
}
catch{
    Write-Output "There is no system-assigned user identity. Aborting."; 
    exit
}

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $resourceGroup) {
    Write-Output "Resource Group $resourceGroupName cannot be found."
    exit
}

$vms = Get-AzVM -ResourceGroupName $resourceGroupName -Status -ErrorAction SilentlyContinue
if ($null -eq $vms) {
    Write-Output "No VMs found in $resourceGroupName Resource Group."
    exit
}

foreach($vm in $vms) {
    if ($state -eq "Start") {
        if (-Not($vm.PowerState -eq "VM running")) {
            Start-AzVM -Name $vm.Name -ResourceGroupName $resourceGroupName -DefaultProfile $AzureContext
        } else {
            Write-Output "$($vm.Name) is considered running. Current State: $($vm.PowerState). Skipping"
        }
    } else {
        if ($vm.PowerState -eq "VM running") {
            Stop-AzVM -Name $vm.Name -ResourceGroupName $resourceGroupName -DefaultProfile $AzureContext -Force
        } else {
            Write-Output "$($vm.Name) is NOT running. Current State: $($vm.PowerState). Skipping"
        }
    }
} 
