locals {
  tags = merge(var.tags, { ManagedByTerraform = "True" })
}

resource "azurerm_key_vault" "default" {
  name                            = var.name_sufix_append ? "${var.key_vault.name}-kv" : var.key_vault.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = var.key_vault.tenant_id
  enabled_for_disk_encryption     = var.key_vault.enabled_for_disk_encryption
  soft_delete_retention_days      = var.key_vault.soft_delete_retention_days
  purge_protection_enabled        = var.key_vault.purge_protection_enabled
  enabled_for_deployment          = var.key_vault.enabled_for_deployment
  enabled_for_template_deployment = var.key_vault.enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault.enable_rbac_authorization
  public_network_access_enabled   = var.key_vault.public_network_access_enabled
  sku_name                        = var.key_vault.sku_name
  tags                            = local.tags

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : ["enabled"]
    content {
      default_action             = var.network_acls.default_action
      bypass                     = var.network_acls.bypass
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }
}

#azurerm_key_vault_access_policy
#azurerm_key_vault_certificate_contacts

#######
# Create private endpoint
#######

module "private-endpoint" {
  for_each            = var.private_endpoint == null ? [] : toset(["vault"])
  source              = "jsathler/private-endpoint/azurerm"
  version             = "0.0.2"
  location            = var.location
  resource_group_name = var.resource_group_name
  name_sufix_append   = var.name_sufix_append
  tags                = local.tags

  private_endpoint = {
    name                           = var.private_endpoint.name
    subnet_id                      = var.private_endpoint.subnet_id
    private_connection_resource_id = azurerm_key_vault.default.id
    subresource_name               = "vault"
    application_security_group_ids = var.private_endpoint.application_security_group_ids
    private_dns_zone_id            = var.private_endpoint.private_dns_zone_id
  }
}
