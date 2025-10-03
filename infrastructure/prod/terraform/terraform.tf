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
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
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
  subscription_id     = "c83f29ee-51b9-48dd-80f1-048acbca4b9a"
  storage_use_azuread = true
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}