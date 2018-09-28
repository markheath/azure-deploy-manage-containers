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

# deploy the mesh application
$templateFile = ".\m7-sfmesh-windows.json"
az mesh deployment create -g $resGroup --template-file $templateFile

# get public ip address
$networkName = "sampleappNetwork"
$publicIp = az mesh network show -g $resGroup  --name $networkName --query "ingressConfig.publicIpAddress" -o tsv

# let's see if it's working
start http://$publicIp

# get status of application
$appName = "sampleapp"
az mesh app show -g $resGroup --name $appName

# view logs for front-end container
$frontEndServiceName = "frontend"
$frontEndCodePackageName = "frontend"
az mesh code-package-log get -g $resGroup --application-name $appName --service-name $frontEndServiceName --replica-name 0 --code-package-name $frontEndCodePackageName

# see number of front end instances
az mesh service show -g $resGroup --name $frontEndServiceName --app-name $appName --query "replicaCount"

# scale up with a fresh deployment
az mesh deployment create -g $resGroup --template-file $templateFile --parameters .\m7-scale-front-end-params.json

# see number of front end instances
az mesh service show -g $resGroup --name $frontEndServiceName --app-name $appName --query "replicaCount"

# see summary of services
az mesh service list -g $resGroup --app-name $appName -o table

# delete everything
az group delete -n $resGroup -y