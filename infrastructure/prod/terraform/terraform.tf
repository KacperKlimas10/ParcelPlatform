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
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}