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
  source        = "Azure/avm-utl-regions/azurerm"
  version       = "0.9.0"
  region_filter = [var.azure_region]
}

module "azure_resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = "${local.azure_resourcegroup_name}_${local.env}"
  location = var.azure_region
  tags     = var.azure_application_tags
}

resource "tls_private_key" "azure_aks_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "azure_aks_key" {
  name                = "akskey"
  resource_group_name = module.azure_resource_group.name
  location            = var.azure_region
  public_key          = tls_private_key.azure_aks_key.public_key_openssh
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

module "azure_node_vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.11.0"
  address_space = ["10.1.0.0/16"]
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
      address_prefixes = ["10.1.0.0/24"]
    }
    "subnet2" = {
      name             = "${local.azure_subnet_name}2_${local.env}"
      address_prefixes = ["10.1.1.0/24"]
    }
    "subnet3" = {
      name             = "${local.azure_subnet_name}3_${local.env}"
      address_prefixes = ["10.1.2.0/24"]
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
  sku_tier            = "Standard"
  default_node_pool = { # System Node VirtualMachineScaleSets
    name                 = "systemnode"
    vm_size              = "Standard_A4_v2" # 4 vCPU 8 GB
    os_sku               = "AzureLinux"
    auto_scaling_enabled = true
    min_count            = 1
    node_count           = 1
    max_count            = 3
    vnet_subnet_id       = module.azure_node_vnet.subnets["subnet1"].resource_id
    zones                = ["1", "2", "3"] # All Availability Zones
    tags                 = var.azure_application_tags
  }
  node_pools = {
    "node1" = { # User Node VirtualMachineScaleSets
      name                 = "usrnode1"
      vm_size              = "Standard_A4_v2" # 4 vCPU 8 GB
      os_sku               = "AzureLinux"
      auto_scaling_enabled = true
      min_count            = 1
      node_count           = 1
      max_count            = 3
      vnet_subnet_id       = module.azure_node_vnet.subnets["subnet2"].resource_id
      zones                = ["1", "2", "3"] # All Availability Zones
      tags                 = var.azure_application_tags
    }
    "node2" = { # User Node VirtualMachineScaleSets
      name                 = "usrnode2"
      vm_size              = "Standard_A2_v2" # 2 vCPU 4 GB
      os_sku               = "AzureLinux"
      auto_scaling_enabled = true
      min_count            = 1
      node_count           = 1
      max_count            = 3
      vnet_subnet_id       = module.azure_node_vnet.subnets["subnet3"].resource_id
      zones                = ["1", "2", "3"]
      tags                 = var.azure_application_tags
    }
  }
  dns_prefix                      = "parcelplatform"
  create_nodepools_before_destroy = true
  linux_profile = {
    admin_username = "parcelplatform_admin"
    ssh_key        = azurerm_ssh_public_key.azure_aks_key.public_key
  }
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
  source                  = "Azure/avm-res-containerregistry-registry/azurerm"
  version                 = "0.5.0"
  location                = var.azure_region
  name                    = module.azure_naming.container_registry.name_unique
  resource_group_name     = module.azure_resource_group.name
  sku                     = "Premium"
  zone_redundancy_enabled = true
  tags                    = var.azure_application_tags
}

data "azurerm_container_registry" "azure_container_registry" {
  name                = module.azure_container_registry.name
  resource_group_name = module.azure_resource_group.name
  depends_on          = [module.azure_container_registry]
}

/* HELM */

resource "helm_release" "kong_gateway_operator" {
  name             = "kong-operator"
  repository       = "https://charts.konghq.com"
  chart            = "kong-operator"
  namespace        = "kong-system"
  create_namespace = true
  set = [
    {
      name  = "env.ENABLE_CONTROLLER_KONNECT"
      value = true
    },
    {
      name  = "global.webhooks.options.certManager.enabled"
      value = true
    }
  ]
  depends_on = [module.azure_aks, helm_release.cert_manager]
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true
  set = [
    {
      name  = "defaultRevision"
      value = "default"
    }
  ]
  depends_on = [module.azure_aks]
}

resource "helm_release" "istio_d" {
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  wait             = true
  depends_on       = [module.azure_aks]
}
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.19.0"
  namespace        = "cert-manager"
  create_namespace = true
  set = [
    {
      name  = "crds.enabled"
      value = true
    }
  ]
  depends_on = [module.azure_aks]
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true
  values = [
    <<-EOF
      apiVersion: v1
      data:
        apiKey: ${var.cloudflare_api_token}
        email: ${var.cloudflare_account_email}
      kind: Secret
      metadata:
        creationTimestamp: null
        name: cloudflare-api-key
      ---
      provider:
        name: cloudflare
      env:
        - name: CF_API_KEY
        valueFrom:
          secretKeyRef:
            name: cloudflare-api-key
            key: apiKey
        - name: CF_API_EMAIL
        valueFrom:
          secretKeyRef:
            name: cloudflare-api-key
            key: email
    EOF
  ]
  depends_on = [module.azure_aks]
}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  # values = [
  #   <<-EOF
  #     redis-ha:
  #       enabled: true
  #     controller:
  #       replicas: 1
  #     server:
  #       autoscaling:
  #         enabled: true
  #         minReplicas: 2
  #     repoServer:
  #       autoscaling:
  #         enabled: true
  #         minReplicas: 2
  #     applicationSet:
  #       replicas: 2
  #   EOF
  # ]
  depends_on = [module.azure_aks]
}

resource "helm_release" "vault" {
  name             = "vault-secrets-operator"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault-secrets-operator"
  version          = "0.10.0"
  namespace        = "vault-secrets-operator"
  create_namespace = true
  depends_on       = [module.azure_aks]
}

resource "helm_release" "prometheus_stack" {
  name             = "kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "kube-prometheus-stack"
  create_namespace = true
  depends_on       = [module.azure_aks]
}