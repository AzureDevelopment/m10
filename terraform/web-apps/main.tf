data "azurerm_key_vault" "example" {
  name                = "m10"
  resource_group_name = "development-in-az"
}

data "azurerm_key_vault_secret" "example" {
  name         = "secret-sauce"
  key_vault_id = data.azurerm_key_vault.example.id
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "m10-terraform-test-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.example.fully_qualified_domain_name};Database=${azurerm_sql_database.example.name};User ID=${var.db_user};Password=${data.azurerm_key_vault_secret.example.value};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "example" {
  name                         = "m10-test-1"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.db_user
  administrator_login_password = data.azurerm_key_vault_secret.example.value
}

resource "azurerm_sql_database" "example" {
  name                = "myexamplesqldatabase"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.example.name
}



resource "azurerm_storage_account" "example_2" {
  name                     = "m10storagetest2"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example_func" {
  name                = "azure-functions-test-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "example" {
  name                      = "m10-func-test-1"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  app_service_plan_id       = azurerm_app_service_plan.example_func.id
  storage_connection_string = azurerm_storage_account.example_2.primary_connection_string
}