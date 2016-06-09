# Create the variable to hold the resource group name
$RGPName = ”srieger-hsfd”

# Create the variable to hold the Azure region
$location= ”westeurope”

# Create the Resource Group
Write-Output "Creating ResourceGroup $RGPName..."
New-AzureRmResourceGroup -Name $RGPName -Location $location

# Create the variable to hold the storage account name
$STAName= ”sriegerhsfdsawe”

# Create the variable to hold the type of storage model to use
$STAType= “Standard_GRS”

# Create the storage account and store the reference to a variable
Write-Output "Creating StorageAccount $STAName..."
$STA = New-AzureRmStorageAccount -Name $STAName -ResourceGroupName $RGPName –Type $STAType -Location $location

# Create the variable to hold the name of the NIC
$NICName=”$RGPName-VM1NIC”

# Create the variable to hold the static IP address that will be assigned to the NIC
$staticIP= “10.0.64.4”

# Create the virtual network name
$subnetName = "$RGPName-Subnet-1"
$netName = "$RGPName-Net-1"

Write-Output "Creating Subnet $subnetName..."
$snet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName `
   -AddressPrefix "10.0.64.0/24"

Write-Output "Creating VirtualNetwork $netName..."
$vnet = New-AzureRmVirtualNetwork -Name $netName `
   -ResourceGroupName $RGPName `
   -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $snet

$snet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName `
   -VirtualNetwork $vnet

# Get the reference to the vNet that has the subnet being targeted
$vNet = Get-AzureRMVirtualNetwork -ResourceGroupName $RGPName -Name $netName

# Get a reference to the Subnet to attach the NIC
$Subnet = $vNet.Subnets | Where-Object {$_.Name -eq $subnetName}

# Create a public IP address object that can be assigned to the NIC
Write-Output "Creating PublicIpAddress for $NICName..."
$pubIP = New-AzureRmPublicIpAddress -Name $NICName -ResourceGroupName $RGPName -Location $location -AllocationMethod Dynamic

#Create the NIC attached to a subnet, with a public facing IP, and a static private IP
Write-Output "Creating NetworkInterface for $NICName..."
$NIC = New-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGPName -Location $location -SubnetId $Subnet.Id -PublicIpAddressId $pubIP.Id -PrivateIpAddress $staticIP

# Create the variable that will store the size of the VM
$vmSize=”Standard_DS1”

# Create the variable that will hold the name of the virtual machine
$vmName=”vm1-windows”

# Create the virtual machine configuration object and save a reference to it
Write-Output "Creating VmConfig for $vmName..."
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

# Create the variable to hold the publisher name
$pubName = ”MicrosoftWindowsServer”

# Create the variable to hold the offer name
$offerName = ”WindowsServer”

# Create the variable to hold the SKU name
$skuName = ”2012-R2-Datacenter”

# Create the variable to hold the OS disk name
$diskName = ”VM1OSDisk”

# credentials that will be used for the local admin password for the VM
#$cred = Get-Credential -Message “Type the name and password of the local administrator account.”
$username = "srieger"
$password = ConvertTo-SecureString 'Test_1234' –AsPlainText –Force
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password

# Assign the operating system to the VM configuration
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

# Assign the gallery image to the VM configuration
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"

# Assign the NIC to the VM configuration
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $NIC.Id

# Create the URI to store the OS disk VHD
$OSDiskUri = $STA.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName  + ".vhd"

# [optional] Assign the OS Disk name and location to the VM configuration
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $OSDiskUri -CreateOption fromImage

# Create Windows VM
Write-Output "Creating Windows vm $vmName..."
New-AzureRmVM -ResourceGroupName $RGPName -Location $location -VM $vm

# Create Linux VM

# Create the variable to hold the name of the NIC
$NICName=”$RGPName-VM2NIC”

# Create the variable to hold the static IP address that will be assigned to the NIC
$staticIP= “10.0.64.5”

# Create a public IP address object that can be assigned to the NIC
Write-Output "Creating PublicIpAddress for $NICName..."
$pubIP = New-AzureRmPublicIpAddress -Name $NICName -ResourceGroupName $RGPName -Location $location -AllocationMethod Dynamic

#Create the NIC attached to a subnet, with a public facing IP, and a static private IP
Write-Output "Creating NetworkInterface for $NICName..."
$NIC = New-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGPName -Location $location -SubnetId $Subnet.Id -PublicIpAddressId $pubIP.Id -PrivateIpAddress $staticIP

# Create the variable that will hold the name of the virtual machine
$vmName=”vm2-linux”

# Create the variable that will store the size of the VM
$vmSize=”Standard_DS1”

# Create the virtual machine configuration object and save a reference to it
Write-Output "Creating VmConfig for $vmName..."
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

# Create the variable to hold the publisher name
$pubName = ”Canonical”

# Create the variable to hold the offer name
$offerName = ”UbuntuServer”

# Create the variable to hold the SKU name
$skuName = ”14.04”

# Create the variable to hold the OS disk name
$diskName = ”VM2OSDisk”

# credentials that will be used for the local admin password for the VM
#$cred = Get-Credential -Message “Type the name and password of the local administrator account.”
$username = "srieger"
$password = ConvertTo-SecureString 'Test_1234' –AsPlainText –Force
$cred = New-Object System.Management.Automation.PSCredential $username, $password

# Assign the operating system to the VM configuration
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $vmName -Credential $cred

# Assign the gallery image to the VM configuration
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"

# Assign the NIC to the VM configuration
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $NIC.Id

# Create the URI to store the OS disk VHD
$OSDiskUri = $STA.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName  + ".vhd"

# [optional] Assign the OS Disk name and location to the VM configuration
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $OSDiskUri -CreateOption fromImage

# Create Linux VM
Write-Output "Creating Linux vm $vmName..."
New-AzureRmVM -ResourceGroupName $RGPName -Location $location -VM $vm


# Create some web sites
Write-Output "Creating webapps $RGPName-webapp1 and $RGPName-webapp2..."
New-AzureRmWebApp -Location $location -Name "$RGPName-webapp1" -ResourceGroupName $RGPName
New-AzureRmWebApp -Location $location -Name "$RGPName-webapp2" -ResourceGroupName $RGPName

