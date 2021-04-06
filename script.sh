# 0. Variables
STORAGE_ACCOUNT_NAME="YOUR_STORAGE_ACCOUNT_NAME"
STORAGE_ACCOUNT_ACCESS_KEY="YOUR_STORAGE_ACCOUNT_ACCESS_KEY"

# 1. Create Azure Logic Apps Connections

cd terraform/1.api-connections

terraform init \
    -backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
    -backend-config="container_name=video-indexer-flow" \
    -backend-config="key=api-connections.tfstate" \
    -backend-config="access_key=${STORAGE_ACCOUNT_ACCESS_KEY}"

terraform validate
terraform plan -var="azuread_domain=YOUR_DOMAIN.onmicrosoft.com" -out api-connections.tfplan
terraform apply api-connections.tfplan



# 2. Create Azure Function and Azure Media Services account

cd terraform/2.azure-function

terraform init \
    -backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
    -backend-config="container_name=video-indexer-flow" \
    -backend-config="key=azure-function.tfstate" \
    -backend-config="access_key=${STORAGE_ACCOUNT_ACCESS_KEY}"

terraform validate
terraform plan -var="remote_states_access_key=${STORAGE_ACCOUNT_ACCESS_KEY}" -out azure-function.tfplan
terraform apply azure-function.tfplan

# 2.1 IMPORTAT: You have to deploy AMSv3Indexer in the Azure Function

# 3. Create Azure Logic App workflow

cd terraform/3.workflow

terraform init \
    -backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
    -backend-config="container_name=video-indexer-flow" \
    -backend-config="key=workflow.tfstate" \
    -backend-config="access_key=${STORAGE_ACCOUNT_ACCESS_KEY}"

terraform validate
terraform plan -var="remote_states_access_key=${STORAGE_ACCOUNT_ACCESS_KEY}" -out workflow.tfplan
terraform apply workflow.tfplan
