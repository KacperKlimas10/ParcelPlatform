resource "cloudflare_registrar_domain" "parcel_platform_domain" {
  account_id  = var.cloudflare_accountId
  domain_name = "parcelplatform.org"
  auto_renew  = false
}