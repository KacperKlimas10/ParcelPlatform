variable "cloudflare_account_email" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_domain_name" {
  type = string
}
variable "azure_application_suffix" {
  type    = list(string)
  default = ["parcelplatform"]
}

variable "azure_application_tags" {
  type = map(any)
  default = {
    "appname" : "parcelplatform"
    "env" : "dev"
  }
}

variable "azure_region" {
  type    = string
  default = "eastus2"
}

variable "azure_subscription_id" {
  type = string
}