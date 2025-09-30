terraform {
  required_version = "~> 1.13.3"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.10.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.45.1"
    }
  }
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}