resource "azurerm_container_registry" "maples" {
  name                     = var.registry_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = "Premium"
  admin_enabled            = true
  georeplications {
    location = var.location_secondary
    tags = merge(var.tags, {
        resource-type = "ContainerRegistryGeoReplication"
        resource-sku  = "Premium"
    })
  }
  tags = merge(var.tags, {
    resource-type = "ContainerRegistry"
    resource-sku  = "Premium"
  })

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.maples.id
    ]
  }

  encryption {
    enabled            = true
    key_vault_key_id   = azurerm_key_vault_key.maples.id
    identity_client_id = azurerm_user_assigned_identity.maples.client_id
  }
}

resource "azurerm_user_assigned_identity" "maples" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name = var.registry_managed_identity_name
  tags = merge(var.tags, {
    resource-type = "UserAssignedIdentity"
    resource-sku  = "None"
  })
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "maples" {
  name                        = var.registry_key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  tags = merge(var.tags, {
    resource-type = "KeyVault"
    resource-sku  = "Standard"
  })

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "UnwrapKey",
      "WrapKey"
    ]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.maples.tenant_id
    object_id = azurerm_user_assigned_identity.maples.principal_id

    key_permissions = [
      "Get",
      "UnwrapKey",
      "WrapKey"
    ]
  }
}

resource "azurerm_key_vault_key" "maples" {
  name         = "container-registry-key"
  key_vault_id = azurerm_key_vault.maples.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
}
