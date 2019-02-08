# Discovery Day - Multi-cloud Orchestration with Terraform

Multi-cloud Orchestration with Terraform

Join us for a 1-day deep technical hands-on workshop where our subject matter experts will take you through the fundamentals of using Terraform to manage the deployment and removal of simple Azure services, through to modularizing your own standards to effectively manage large scale deployments.

Engage with technical subject matter experts who can help demonstrate how to solve your challenges with a variety of approaches using Azure technologies.

# Workshops
There will be 3 workshops from IaaS, PaaS to Kubernetes deployment

## Workshop 1
Infrastructure as a Service - In this workshop we will create;
- Resource Group
- VNet - Subnet
- NSG attached to Subnet which allows SSH port.
- NIC with a public IP
- Virtual Machine with Managed disk attach NIC card to VM


## Workshop 2
Platform as a Service- In this workshop we will create;
- 3 Resource Group - one central - management, two satellite region
- App Service Plan and App services for each satellite regions 
	- Assign host names of the App Services as App Settings
- Traffic Manager Profile and SQL Database in central regions
	- Attach two App Services as End points to TM
	- Assign SQL Database information as Connection String to App Services

## Workshop 3
Kubernetes, AKS is the managed Kubertenes services from Azure - In this workshop we will create;
For this Workshop you would need to create Service Pricincipal before. Please see - https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
- Resource Group
- Two D1_V2 Linux Nodes AKS cluster. ( You will see it's so easy! )
