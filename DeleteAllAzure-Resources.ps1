# The following PowerShell script can be used to delete all resources
# used in Azure for Cloud Computing in Master Global Software Development
# at Hochschule Fulda in Summer Term 2016

# To use this script you must install PowerShell Azure extensions as
# described at: https://azure.microsoft.com/de-de/documentation/articles/powershell-install-configure/
#
# Before starting this script, you need to login to Azure (as described in the
# documentation above, by issuing a "Add-AzureRmAccount" in PowerShell. You can
# also remove the comment in front of the next line to do a login everytime you
# run this script:

# Add-AzureRmAccount

###
### Configuration
###

# arrays define names of resources that should not be deleted
$webappsToRetain = "srieger-hsfd-webapp3"
$vMsToRetain = "vm1", "vm2"
$resourcesToRetain = "resource1", "resource2"
$resourceGroupsToRetain = "srieger-hsfd2"

###
### Code
###

# Display a requester as a warning for the user and get user's consent
# to delete all resources in the active Azure Account and
# subscription
$title = "Delete all Azure resources in subscription 'Azure Pass'"
$message = "Do you really want to delete all Azure Resources in your subscription 'Azure Pass'?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
	"Deletes all Azure resources."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
	"Retains all Azure resources."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
# Display the dialog and get the result
$result = $host.ui.PromptForChoice($title, $message, $options, 1) 

# if the users answered yes, delete all resources
if ($result -eq 0)
{
    # get all webapps in the subscription, leaving out webapps that should be retained
    $webapps = Get-AzureRmWebApp 
    $webappsfiltered = $webapps | Where {$_.Name -notin $webappsToRetain}
    foreach ($webapp in $webappsfiltered)
    {
		# issue the deletion
        Write-Output "Deleting WebApp: $webapp.Name"
        Remove-AzureRmWebApp -Name $webapp.Name -ResourceGroupName $webapp.ResourceGroup -Force -Verbose
    }

    # get all VMs in the subscription, leaving out VMs that should be retained
    $vms = Get-AzureRmVM
    $vmsfiltered = $vms | Where {$_.Name -notin $vMsToRetain}
    foreach ($vm in $vmsfiltered)
    {
		# issue the deletion
        Write-Output "Deleting VM: $vm.Name"
        Remove-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force -Verbose
    }

    # get all resources in the subscription, leaving out resources that should be retained
    $resources = Get-AzureRmResource
    $resourcesfiltered = $resources | Where {$_.Name -notin $resourcesToRetain}
    foreach ($resource in $resourcesfiltered)
    {
		# leave out web apps and VMs (that are also resources) as they were handled above
		# otherwise retained web apps and VMs would be deleted ;)
		if (($resource.ResourceType -ne "Microsoft.Web/sites") -and ($resource.ResourceType -ne "Microsoft.Compute/virtualMachines"))
        {
			# issue the deletion
            Write-Output "Deleting ResourceId: $resource.ResourceId"
            Remove-AzureRmResource -ResourceId $resource.ResourceId -Force -Verbose
        }
    }

    # get all resource groups in the subscription, leaving out resource groups that should be retained
    $resourcegroups = Get-AzureRmResourceGroup 
    $resourcegroupsfiltered = $resourcegroups | Where {$_.ResourceGroupName -notin $resourceGroupsToRetain}
    foreach ($resourcegroup in $resourcegroupsfiltered)
    {
		# issue the deletion
        Write-Output "Deleting ResourceGroupName: $resourcegroup.ResourceGroupName"
        Remove-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Force -Verbose
    }

    # You can control the deletion by checking all available resources:
    #Get-AzureRmResource

}