output "azure_aks_host" {
  value     = module.azure_aks.host
  sensitive = true
}

output "azure_aks_cert" {
  value     = module.azure_aks.cluster_ca_certificate
  sensitive = true
}

output "azure_aks_fqdn" {
  value = module.azure_aks.public_fqdn
}

