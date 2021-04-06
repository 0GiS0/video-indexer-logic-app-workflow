
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}

output "storage_id" {
  value = azurerm_storage_account.storage.id
}

output "storage_name" {
  value = azurerm_storage_account.storage.name
}

output "eventgrid_link" {
  value = "${var.azure_portal_url}/#@${var.azuread_domain}/resource/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/azureeventgrid/edit"
}

output "azureblob_link" {
  value = "${var.azure_portal_url}/#@${var.azuread_domain}/resource/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/azureblob/connection"
}

output "cosmosdb_link" {
  value = "${var.azure_portal_url}#@${var.azuread_domain}/resource/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/documentdb/connection"
}