provider "azurerm" {
  version                   = ">=2.0.0"
  skip_provider_registration = true
  client_id                 = "${var.clientId}"
  client_certificate_path   = "../service-principal.pfx"
  subscription_id           = "${var.subscriptionId}"
  tenant_id                 = "${var.tenantId}"
  features {} 
}
