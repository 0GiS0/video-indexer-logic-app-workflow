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

#ARM Template: Azure Logic App
resource "azurerm_template_deployment" "logic_app" {
  name                = random_pet.service.id
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_body       = file("../../arm-templates/logic-app-workflow.json")
  parameters = {
    "api_connections_location"       = data.terraform_remote_state.api_connections.outputs.resource_group_location
    "location"                       = azurerm_resource_group.rg.location
    "workflow_name"                  = random_pet.service.id
    "api_connections_resource_group" = data.terraform_remote_state.api_connections.outputs.resource_group_name
    "storage_resource_group"         = data.terraform_remote_state.api_connections.outputs.resource_group_name
    "storage_name"                   = data.terraform_remote_state.api_connections.outputs.storage_name
    "azure_function_resource_group"  = data.terraform_remote_state.azure_function.outputs.resource_group_name
    "azure_function_name"            = data.terraform_remote_state.azure_function.outputs.azure_function_name
  }
}
