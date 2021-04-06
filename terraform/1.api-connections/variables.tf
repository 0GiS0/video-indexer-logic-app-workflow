variable "location" {
  default = "northeurope"
}

variable "azure_portal_url" {
  default = "https://portal.azure.com"
}

variable "azuread_domain" {  
}

variable "cosmosdb_db" {
  default = "Insights"
}

variable "cosmosdb_container" {
  default = "videos"
}

variable "cosmosdb_partition_key" {
  default = "/sourceLanguage"
}
