### Backend ###

terraform {
  backend "azurerm" {

  }
}

### Providers ###

provider "azurerm" {
  features {}
}

provider "azuread" {
}

### Resources ###

#Random name
resource "random_pet" "service" {}

#Resource group
resource "azurerm_resource_group" "rg" {
  name     = random_pet.service.id
  location = var.location
}

#Azure Media Services
resource "azurerm_media_services_account" "ams" {
  name                = replace(random_pet.service.id, "-", "")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  identity {
    type = "SystemAssigned"
  }

  storage_account {
    id         = data.terraform_remote_state.api_connections.outputs.storage_id
    is_primary = true
  }
}


#Azure Function

resource "azurerm_app_service_plan" "plan" {
  name                = random_pet.service.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}


### Azure Function for AMS ###

#Azure Storage for Function App
resource "azurerm_storage_account" "storage" {
  name                     = replace(random_pet.service.id, "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Application Insights
resource "azurerm_application_insights" "insights" {
  name                = random_pet.service.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}


resource "azurerm_function_app" "function" {
  name                       = random_pet.service.id
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  version = "~3"

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.insights.connection_string
    "FUNCTIONS_EXTENSION_VERSION"           = "~3"
    "FUNCTIONS_WORKER_RUNTIME"              = "dotnet"
    "WEBSITE_RUN_FROM_PACKAGE"              = 1
  }

  provisioner "local-exec" {
    command = "az ams account sp create --account-name ${azurerm_media_services_account.ams.name} --resource-group ${azurerm_resource_group.rg.name} | jq 'with_entries( .key = \"AzureMediaServices__\"+.key)' > settings.json && az webapp config appsettings set -g ${azurerm_resource_group.rg.name} -n ${azurerm_function_app.function.name} --settings @settings.json"
  }
}
