### Backend ###

terraform {
  backend "azurerm" {

  }
}

### Providers ###

provider "azurerm" {
  features {}
}

### Resources ###

#Random name
resource "random_pet" "service" {}

#Resource group
resource "azurerm_resource_group" "rg" {
  name     = random_pet.service.id
  location = var.location
}

#Azure Storage
resource "azurerm_storage_account" "storage" {
  name                = replace(random_pet.service.id, "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

}

#CosmosDB
resource "azurerm_cosmosdb_account" "cosmosdbaccount" {
  name                = random_pet.service.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

}

#CosmosDB - Database
resource "azurerm_cosmosdb_sql_database" "cosmosdb_db" {
  name                = var.cosmosdb_db
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdbaccount.name
  throughput          = 400
}

#CosmosDB - Container
resource "azurerm_cosmosdb_sql_container" "cosmosdb_container" {
  name                  = var.cosmosdb_container
  resource_group_name   = azurerm_resource_group.rg.name
  account_name          = azurerm_cosmosdb_account.cosmosdbaccount.name
  database_name         = azurerm_cosmosdb_sql_database.cosmosdb_db.name
  partition_key_path    = var.cosmosdb_partition_key
  partition_key_version = 1
  throughput            = 400
}


# ARM Template: Event grid connection
resource "azurerm_template_deployment" "eventgrid_connection" {
  name                = "eventgrid_connection"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../../arm-templates/azureeventgrid-connection.json")

  parameters = {
    "location" = azurerm_resource_group.rg.location
  }
}

# ARM Template: Azure Blob Connection
resource "azurerm_template_deployment" "azureblob_connection" {
  name                = "azureblob_connection"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../../arm-templates/azureblob-connection.json")

  parameters = {
    "location"    = azurerm_resource_group.rg.location
    "accountName" = azurerm_storage_account.storage.name
    "accessKey"   = azurerm_storage_account.storage.primary_access_key
  }
}

# ARM Template: CosmosDB Connection
resource "azurerm_template_deployment" "cosmosdb_connection" {
  name                = "cosmosdb_connection"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../../arm-templates/cosmosdb-connection.json")

  parameters = {
    "location"    = azurerm_resource_group.rg.location
    "databaseAccount" = azurerm_cosmosdb_account.cosmosdbaccount.name
    "accessKey"   = azurerm_cosmosdb_account.cosmosdbaccount.primary_key
  }
}
