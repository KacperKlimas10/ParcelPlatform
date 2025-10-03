/* CLOUDFLARE */
resource "cloudflare_zone" "parcel_platform_zone" {
  account = {
    id = var.cloudflare_account_id
  }
  name = var.cloudflare_domain_name
  type = "full"
}

resource "cloudflare_dns_record" "azure_blob_dns_record" {
  name    = "blob"
  ttl     = 3600
  type    = "CNAME"
  zone_id = cloudflare_zone.parcel_platform_zone.id
  comment = "CNAME record for Azure Blob Storage"
  content = data.azurerm_storage_account.azure_storage_account.primary_blob_host
}

resource "cloudflare_dns_record" "azure_registry_dns_record" {
  name    = "registry"
  ttl     = 3600
  type    = "CNAME"
  zone_id = cloudflare_zone.parcel_platform_zone.id
  comment = "CNAME record for Azure Container Registry"
  content = data.azurerm_container_registry.azure_container_registry.login_server
}

/* AZURE */

locals {
  env                      = var.azure_application_tags.env
  azure_resourcegroup_name = module.azure_naming.resource_group.name_unique
  azure_vnet_name          = module.azure_naming.virtual_network.name_unique
  azure_subnet_name        = module.azure_naming.subnet.name_unique
}

resource "azuread_application" "parcel_platform" {
  display_name = "parcelplatform"
  owners       = [data.azuread_client_config.parcel_platform.object_id]
}

resource "azuread_service_principal" "parcel_platform" {
  client_id                    = azuread_application.parcel_platform.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.parcel_platform.object_id]
  feature_tags {
    enterprise = true
    gallery    = true
  }
}

resource "azuread_service_principal_password" "parcel_platform" {
  service_principal_id = azuread_service_principal.parcel_platform.id
}

data "azuread_client_config" "parcel_platform" {}

module "azure_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = var.azure_application_suffix
}

module "azure_regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.9.0"
}

module "azure_resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = "${local.azure_resourcegroup_name}1_${local.env}"
  location = var.azure_region
  tags     = var.azure_application_tags
}

# module "azure_firewall" {
#   source              = "Azure/avm-res-network-azurefirewall/azurerm"
#   version             = "0.4.0"
#   firewall_sku_name   = "AZFW_VNet"
#   firewall_sku_tier   = "Standard"
#   location            = var.azure_region
#   name                = module.azure_naming.firewall.name_unique
#   resource_group_name = module.azure_resource_group.name
#   tags                = var.azure_application_tags
# }

module "azure_vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.11.0"
  address_space = ["10.0.0.0/16"]
  location      = var.azure_region
  dns_servers = {
    dns_servers = [
      "1.1.1.1", # Cloudflare DNS
      "1.0.0.1", # Cloudflare DNS
      "8.8.8.8"  # Google DNS
    ]
  }
  name      = "${local.azure_vnet_name}_${local.env}"
  parent_id = module.azure_resource_group.resource_id
  subnets = {
    "subnet1" = {
      name             = "${local.azure_subnet_name}1_${local.env}"
      address_prefixes = ["10.0.0.0/24"]
    }
    "subnet2" = {
      name             = "${local.azure_subnet_name}2_${local.env}"
      address_prefixes = ["10.0.1.0/24"]
    }
    "subnet3" = {
      name             = "${local.azure_subnet_name}3_${local.env}"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
  tags = var.azure_application_tags
}

module "azure_aks" {
  source              = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version             = "0.3.0"
  location            = var.azure_region
  name                = module.azure_naming.kubernetes_cluster.name_unique
  resource_group_name = module.azure_resource_group.name
  default_node_pool = {
    name                 = "aksnodepool"
    vm_size              = "standard_a2_v2"
    auto_scaling_enabled = true
    max_count            = 4
    min_count            = 2
    node_count           = 2
  }
  dns_prefix = "aks"
  service_principal = {
    client_id     = azuread_service_principal.parcel_platform.client_id
    client_secret = azuread_service_principal_password.parcel_platform.value
  }
  local_account_disabled = false
  tags                   = var.azure_application_tags
}

module "azure_storage_account" {
  source                   = "Azure/avm-res-storage-storageaccount/azurerm"
  version                  = "0.6.4"
  location                 = var.azure_region
  name                     = "parcelplatformblob"
  resource_group_name      = module.azure_resource_group.name
  access_tier              = "Hot"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"
  tags                     = var.azure_application_tags
}

data "azurerm_storage_account" "azure_storage_account" {
  name                = module.azure_storage_account.name
  resource_group_name = module.azure_resource_group.name
  depends_on          = [module.azure_storage_account]
}

module "azure_container_registry" {
  source              = "Azure/avm-res-containerregistry-registry/azurerm"
  version             = "0.5.0"
  location            = var.azure_region
  name                = module.azure_naming.container_registry.name_unique
  resource_group_name = module.azure_resource_group.name
  tags                = var.azure_application_tags
}

data "azurerm_container_registry" "azure_container_registry" {
  name                = module.azure_container_registry.name
  resource_group_name = module.azure_resource_group.name
  depends_on          = [module.azure_container_registry]
}