Terraform Infrastructure Provisioning:

terraform init

1. Create Resource Group:
	terraform plan -target module.ResourceGroup
	terraform apply -target module.ResourceGroup

2. Create Vnet:
	terraform plan -target module.virtualNetwork
	terraform apply -target module.virtualNetwork

3. Create VM:
	terraform plan -target module.virtualMachin
	terraform apply -target module.virtualMachin
	
	if we want to change any of the variable use below command with or change the values in terraform.tfvars

	terraform plan -target module.virtualMachin -var "VM_count=1" -var "VM_size = Standard_DS1_v2" -var "os_version = 22_04-lts-gen2" -var "os_disk_type = Standard_LRS"
	terraform apply -target module.virtualMachin -var "VM_count=1" -var "VM_size = Standard_DS1_v2" -var "os_version = 22_04-lts-gen2" -var "os_disk_type = Standard_LRS"
	
4. Create AKS Cluster:
	terraform plan -target module.AKScluster
	terraform apply -target module.AKScluster
	
	if we want to change any of the variable use below command with or change the values in terraform.tfvars
	
	terraform plan -target module.AKScluster -var "AKS_node_size = Standard_D8s_v3" -var "AKS_version = 1.26.3" -var "AKS_node_count = 1"
	terraform apply -target module.AKScluster -var "AKS_node_size = Standard_D8s_v3" -var "AKS_version = 1.26.3" -var "AKS_node_count = 1"

5. Create HDInsight Cluster:
	terraform plan -target module.HDInsightCluster
	terraform apply -target module.HDInsightCluster

6. Create MYSQL Server:
	terraform plan -target module.mysqlServer
	terraform apply -target module.mysqlServer

7. Create Load Balancer:
	terraform plan -target module.loadBalancer
	terraform apply -target module.loadBalancer

8. Create key vault:
	terraform plan -target module.keyVault
	terraform apply -target module.keyVault
	
9. Create Azure Maps Account:
	terraform plan -target module.azureMapsAccount
	terraform apply -target module.azureMapsAccount
	
10. Create Application Gateway:
	terraform plan -target module.applicationGateway
	terraform apply -target module.applicationGateway

# How to add one more 1 VM
	- chnage the VM Count. (we are passing VM Count as a variable, so just chnage the VM Count)
	
# If we want to update more tags to a RG, what needs to be done what code changes were required.
    - Go to modules-> ResourceGroup-> create new variable with tag name in variables.tf file
	- Go to main.tf file and add tag in locals block
	- then go to Dev/Test/Prod -> create new variable with tag name in variables.tf file
	- Go to main.tf file -> update the ResourceGroup module
	- Update the terraform.tfvars file
 
# I want to create only AKS / only storage acct
	- use "-target module.<module name>" to run specific mudule 

# How to pass the args from the command line
	- pass variables as shown below:
	It will overwrite exsisting values from terraform.tfvars file
	
	terraform plan -var "ResourceGroup_name=uttam-lct-dev-01" -var "ResourceGroup_location=East US" -var "VM_count=2" -var "create_resource_group=true"  -var "create_storage_account=true" -var "create_cdn_endpoint=true" -var "Cost_Center_ID=474000" -var "Environment_Type=Dev" -var  "Product_Group=Luminate Control Tower" -var "Customer=Internal"
	
	
# how can we upgrade the OS version / AKS version
    - Update the terraform.tfvars file with required OS version and AKS version
	
	
# How can we update the OS and data disk for a given VM. What changes do we need to do before we provision a VM
    - Update the terraform.tfvars file with required OS version and data disk type.