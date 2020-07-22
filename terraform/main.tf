variable "client_secret" {
  type = string
  default = "_5T8dCT283clSi6A1Y_T._-9SM5XcFN3Cn"
}

variable "subscription_id" {
  type = string
  default = "279f98e7-bb11-40fb-92c5-237db9a32fb4"
}

provider "azurerm" {
  version = "=2.0.0"
  features {}
  subscription_id = var.subscription_id
  client_id       = "1a260bf0-3818-4c8e-9419-992c3450d7ba"
  client_secret   = var.client_secret
  tenant_id       = "ccf081bc-35a6-44a2-8885-3857973e3e4c"
}

resource "azurerm_resource_group" "example" {
  name     = "m10-test-1-rg"
  location = "northeurope"
}

module "web_apps" {
  source = "./web-apps"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

module "additional" {
  source = "./additional"
  resource_group_name = azurerm_resource_group.example.name
}