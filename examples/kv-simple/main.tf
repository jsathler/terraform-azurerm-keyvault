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
