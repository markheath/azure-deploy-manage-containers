# https://github.com/Azure-Samples/service-fabric-mesh/blob/master/templates/todolist/mesh_rp.windows.json
# https://docs.microsoft.com/en-us/azure/service-fabric-mesh/service-fabric-mesh-tutorial-template-deploy-app
# https://github.com/Azure-Samples/service-fabric-mesh/tree/master/src/todolistapp

az account show --query name -o tsv

# check if the extension we need is available
az extension list
# to install
az extension add --name mesh
# to upgrade
az extension update --name mesh

# create a resource group
$resGroup = "ServiceFabricMeshTest"
az group create -n $resGroup -l "westeurope"

$storageAccountName = "acishare$(Get-Random `
    -Minimum 1000 -Maximum 10000)"

# create a storage account
az storage account create -g $resGroup `
    -n $storageAccountName `
    --sku Standard_LRS

# get the connection string for our storage account
$storageConnectionString = `
    az storage account show-connection-string `
    -n $storageAccountName -g $resGroup `
    --query connectionString -o tsv
# export it as an environment variable
$env:AZURE_STORAGE_CONNECTION_STRING = $storageConnectionString

# Create the file share
$shareName="sfshare"
az storage share create -n $shareName

# get the key for this storage account
$storageKey=$(az storage account keys list `
    -g $resGroup --account-name $storageAccountName `
    --query "[0].value" --output tsv)


$params = @{fileShareName=@{value=$shareName};
           storageAccountName=@{value=$storageAccountName};
           storageAccountKey=@{value=$storageKey}} | ConvertTo-Json -Compress

# deploy the mesh application
$templateFile = ".\m7-sfmesh-volumes.json"
az mesh deployment create -g $resGroup --template-file $templateFile `
 --parameters "{'fileShareName':{'value':'$shareName'},'storageAccountName':{'value':'$storageAccountName'},'storageAccountKey':{'value':'$storageKey'}}"

# get public ip address
$publicIp = az mesh network show -g $resGroup  --name todolistappNetwork --query "ingressConfig.publicIpAddress" -o tsv

# let's see if it's working
iwr http://$publicIp

# get status of application
$appName = "todolistapp"
az mesh app show -g $resGroup --name $appName

# view logs for front-end container
az mesh code-package-log get -g $resGroup --application-name $appName --service-name WebFrontEnd --replica-name 0 --code-package-name WebFrontEnd

# see summary of services
az mesh service list -g $resGroup --app-name $appName -o table

# delete everything
az group delete -n $resGroup -y