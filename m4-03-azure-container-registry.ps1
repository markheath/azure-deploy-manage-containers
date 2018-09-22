# before you begin - make sure you're logged in to the azure CLI
az login

# ensure you choose the correct azure subscription if you have more than one 
az account set -s YourSub

# create a resource group
$resourceGroup = "PluralsightAcr"
az group create -n $resourceGroup -l westeurope

# create a new Azure container registry
$registryName = "pluralsightacr"
az acr create -g $resourceGroup -n $registryName --sku Basic

# log in to our container registry
az acr login -n $registryName

# get the login server name
$loginServer = az acr show -n $registryName `
    --query loginServer --output tsv
# OR: az acr list -g $resourceGroup -q "[].{acrLoginServer:loginServer}" -o table

# see the images we have - should have samplewebapp:v2
docker image ls

# give it a new tag
docker tag samplewebapp:v2 $loginServer/samplewebapp:v2

# push the image to our Azure Container Registry
docker push $loginServer/myaspnetcoreapp:v2

# view the images in our ACR
az acr repository list -n $registryName -o table

# view the tags for the samplewebapp repository
az acr repository show-tags -n $registryName --repository samplewebapp -o table

# delete a repository from the 
az acr repository delete -n $registryName -t samplewebapp:v2

# to delete everything we made in this demo
az group delete -n $resourceGroup