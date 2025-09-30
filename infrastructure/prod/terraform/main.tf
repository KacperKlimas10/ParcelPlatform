resource "cloudflare_zone" "parcel_platform_zone" {
  account = {
    id = var.cloudflare_account_id
  }
  name = var.cloudflare_domain_name
  type = "full"
}

resource "cloudflare_zone_dns_settings" "parcel_platform_zone_dns_settings" {
  zone_id = cloudflare_zone.parcel_platform_zone.id
}

resource "cloudflare_dns_record" "record" {
  name    = "Record"
  type    = "A"
  content = "127.0.0.1"
  ttl     = 0
  zone_id = cloudflare_zone.parcel_platform_zone.id
}

locals {
  env                      = var.azure_application_tags.env
  azure_resourcegroup_name = module.azure_naming.resource_group.name_unique
  azure_vnet_name          = module.azure_naming.virtual_network.name_unique
  azure_subnet_name        = module.azure_naming.subnet.name_unique
}

module "azure_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = var.azure_application_suffix
}

module "azure_resourcegroup" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = "${local.azure_resourcegroup_name}1_${local.env}"
  location = var.azure_region
  tags     = var.azure_application_tags
}

module "azure_vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.11.0"
  address_space = ["10.0.0.0/16"]
  location      = var.azure_region
  dns_servers = {
    dns_servers = [
      "1.1.1.1",
      "8.8.8.8"
    ]
  }
  name      = "${local.azure_vnet_name}1_${local.env}"
  parent_id = module.azure_resourcegroup.resource_id
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
      name             = "${module.azure_naming.subnet.name_unique}3_${local.env}"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
  tags = var.azure_application_tags
}