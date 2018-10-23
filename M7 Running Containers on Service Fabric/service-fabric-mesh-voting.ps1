az account show --query name -o tsv

# check if the extension we need is available
az extension list
# to install
az extension add --name mesh
# to upgrade
az extension update --name mesh

# create a resource group
$resGroup = "ServiceFabricMeshVote"
az group create -n $resGroup -l "westeurope"

# deploy the mesh application
$templateFile = ".\sfmesh-example-voting-app.json"
az mesh deployment create -g $resGroup --template-file $templateFile
# [System.Console]::ResetColor()
# get public ip address
$networkName = "votingNetwork"
$publicIp = az mesh network show -g $resGroup --name $networkName --query "ingressConfig.publicIpAddress" -o tsv

# let's see if it's working
Start-Process http://$($publicIp):8081 # voting
Start-Process http://$($publicIp):8082 # results

# get status of application
$appName = "votingApp"
az mesh app show -g $resGroup --name $appName

# view logs for vote container
az mesh code-package-log get -g $resGroup --application-name $appName --service-name vote --replica-name 0 --code-package-name vote

# see summary of services
az mesh service list -g $resGroup --app-name $appName -o table

# explore the result service
az mesh service show -g $resGroup --app-name $appName --name result

# look at network
az mesh network show -n votingNetwork -g $resGroup

# scale up vote container to 3 instances (currently seems unreliable)
# https://github.com/Azure/service-fabric-mesh-preview/issues/266
az mesh deployment create -g $resGroup --template-file $templateFile `
 --parameters "{'workerReplicaCount':{'value':'3'}}"

# see services again
az mesh service list -g $resGroup --app-name $appName -o table

# explore the vote service
az mesh service show -g $resGroup --app-name $appName --name vote -o table

# see the replicas
az mesh service-replica list -g $resGroup --app-name $appName --service-name vote -o table

# explore a particular replica
az mesh service-replica show -g $resGroup --app-name $appName --service-name vote --replica-name 0

# delete everything
az group delete -n $resGroup -y