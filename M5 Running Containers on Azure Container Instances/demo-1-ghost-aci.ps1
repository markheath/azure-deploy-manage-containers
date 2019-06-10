# create a new resource group
$resourceGroup = "AciGhostDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create a docker container using the ghost image from dockerhub
$containerGroupName = "ghost-blog1"
$dnsNameLabel = "ghostaci"
az container create -g $resourceGroup -n $containerGroupName `
    --image ghost `
    --ports 2368 `
    --ip-address public `
    --dns-name-label $dnsNameLabel

# see details about this container
az container show `
    -g $resourceGroup -n $containerGroupName

# test it out
Start-Process "http://$dnsNameLabel.westeurope.azurecontainer.io:2368"
Start-Process "http://$dnsNameLabel.westeurope.azurecontainer.io:2368/admin"

# view the logs
az container logs `
    -n $containerGroupName -g $resourceGroup 

# clean up everything
az group delete -n $resourceGroup -y