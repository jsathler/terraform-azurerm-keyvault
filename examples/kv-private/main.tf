locals {
  prefix = "${basename(path.cwd)}-${random_string.default.result}"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${local.prefix}-rg"
  location = "northeurope"
}

data "azurerm_client_config" "default" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "default" {
  length    = 6
  min_lower = 6
}

resource "azurerm_application_security_group" "default" {
  name                = "${local.prefix}-asg"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "vnet" {
  source              = "jsathler/network/azurerm"
  version             = "0.0.2"
  name                = local.prefix
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]

  subnets = {
    default = {
      address_prefixes   = ["10.0.0.0/24"]
      nsg_create_default = false
    }
  }
}

module "private-zone" {
  source              = "jsathler/dns-zone/azurerm"
  version             = "0.0.1"
  resource_group_name = azurerm_resource_group.default.name
  zones = {
    "privatelink.database.windows.net" = {
      private = true
      vnets = {
        "${basename(path.cwd)}-vnet" = { id = module.vnet.vnet_id }
      }
    }
  }
}

module "keyvault" {
  source              = "../../"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  key_vault = {
    name      = local.prefix
    tenant_id = data.azurerm_client_config.default.tenant_id
  }

  network_acls = {
    ip_rules = [chomp(data.http.myip.response_body)]
  }
}
