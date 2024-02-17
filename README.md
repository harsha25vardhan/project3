# How to store Terraform state file in Azure Storage | How to manage Terraform state in Azure Blob Storage | Terraform Remote state in Azure Blob storage | Terraform backend

One of the amazing features of Terraform is, it tracks the infrastructure that you provision. It does this through the means of state. By default, Terraform stores state information locally in a file named terraform.tfstate. This does not work well in a team environment where if any developer wants to make a change he needs to make sure nobody else is updating terraform in the same time. You need to use remote storage to store state file.

With remote state, Terraform writes the state data to a remote data store, which can then be shared between all members of a team. Terraform supports storing state in many ways including the below:

Terraform Cloud
HashiCorp Consul
Amazon S3
Azure Blob Storage
Google Cloud Storage
Alibaba Cloud OSS
Artifactory or Nexus 

so in this i am to store state file in Azure Blob storage. i am creating Azure storage account and container.

Pre-requisites:
Install Azure CLI
Make sure Terraform is setup on your local machine
Azure subscription 
Authenticate Terraform with Azure using Azure CLI.

## Step1:- Logging into the Azure Cloud
Login into the Azure Cloud using Azure CLI using:

az login
enter your microsoft username and password to login to Azure cloud

Create main.tf


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.63.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo-rg" {
  name     = "demo-resource-group"
  location = "eastus"
}

terraform init 
terraform plan 
this will show it will create one resource

terraform apply 
Now this will create a local terraform state file in your machine.

## Step 2 - To store Terraform state file remotely
Configure Azure storage account
Before you use Azure Storage as a backend, you must create a storage account. We will create using shell script:

create-storage.sh

#!/bin/bash
RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate
#Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus
#Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
#Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

This should have created resource group, storage account and container in Azure portal.

## Step 3 - Configure terraform backend state 
To configure the backend state, you need the following Azure storage information which we created above:

resource_group_name: name of the resource group under which all resources will be created.
storage_account_name: The name of the Azure Storage account.
container_name: The name of the blob container.
key: The name of the state store file to be created.

Create backend.tf file
We need to create a backend file.

terraform {
    backend "azurerm" {
        resource_group_name  = "tfstate"
        storage_account_name = "<storage_acct_name>"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
}


terraform init --reconfigure
type yes
This should have created backend file called terraform.tfstate in a container inside azure storage.
You can view remote state file info.
This is how you can store terraform state information remotely in Azure storage. 

Now let's make changes to main.tf to create more resources
edit main.tf

resource "azurerm_container_registry" "acr" {
  name                = "myacr563123"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

terraform plan

terraform apply --auto-approve

This will update terraform state file remotely in azure blob container.



reference vedio:- https://www.youtube.com/watch?v=A1g8Yu3DZsk