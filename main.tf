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

resource "azurerm_container_registry" "acr" {
  name                = "myacr56312312"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  sku                 = "Standard"
  admin_enabled       = false
}
