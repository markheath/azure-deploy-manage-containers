# this demo to create a private container registry

# create a resource group to use
$resourceGroup = "AciPrivateRegistryDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# ACR we'll be using
$acrName = "pluralsightacr"

# if we've not already created an Azure Container Registry
# az acr create -g $resourceGroup -n $acrName --sku Basic --admin-enabled true

# login to the registry with docker
$acrPassword = az acr credential show -n $acrName `
    --query "passwords[0].value" -o tsv
$loginServer = az acr show -n $acrName `
    --query loginServer --output tsv

# log in to the ACR
az acr login -n $acrName

# if we want to use docker login instead:
# docker login -u $acrName -p $acrPassword $loginServer

$storageAccountName = "acishare$(Get-Random `
    -Minimum 1000 -Maximum 10000)"

# create a storage account
az storage account create -g $resourceGroup `
    -n $storageAccountName `
    --sku Standard_LRS

# get the connection string for our storage account
$storageConnectionString = `
    az storage account show-connection-string `
    -n $storageAccountName -g $resourceGroup `
    --query connectionString -o tsv
# export it as an environment variable
$env:AZURE_STORAGE_CONNECTION_STRING = $storageConnectionString

# Create the file share
$shareName="acishare"
az storage share create -n $shareName

# get the key for this storage account
$storageKey=$(az storage account keys list `
    -g $resourceGroup --account-name $storageAccountName `
    --query "[0].value" --output tsv)

# tag the image we want to use in our registry
$image = "samplewebapp:latest" # can add a tag here
$imageTag = "$loginServer/$image"
docker tag $image $imageTag

# push the image to our registry
docker push $imageTag

# see what images are in our registry
az acr repository list -n $acrName --output table

# create a new container group using the image from the private registry
# username used to need to be $loginServer, but now seems can be $acrname
$containerGroupName = "aci-acr"
az container create -g $resourceGroup `
    -n $containerGroupName `
    --image $imageTag --cpu 1 --memory 1 `
    --registry-username $acrName `
    --registry-password $acrPassword `
    --azure-file-volume-account-name $storageAccountName `
    --azure-file-volume-account-key $storageKey `
    --azure-file-volume-share-name $shareName `
    --azure-file-volume-mount-path "/home" `
    -e TestSetting=FromAzCli2 TestFileLocation=/home/message.txt `
    --dns-name-label "aciacr" --ports 80


# get the site address and launch in a browser
$fqdn = az container show -g $resourceGroup -n $containerGroupName `
    --query ipAddress.fqdn -o tsv
Start-Process "http://$($fqdn)"

# view the logs for our container
az container logs -n $containerGroupName -g $resourceGroup

az container exec -n $containerGroupName -g $resourceGroup --exec-command sh

# within the container:
echo "hello" > /home/message.txt
exit

az storage file list -s $shareName -o table

$downloadPath = "C:\Users\mheath\Downloads\message.txt"
az storage file download -s $shareName -p "message.txt" `
    --dest $downloadPath
Start-Process $downloadPath


az container delete -g $resourceGroup -n $containerGroupName

# delete the resource group (ACR and container group)
az group delete -n $resourceGroup -y