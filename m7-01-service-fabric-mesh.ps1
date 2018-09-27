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
az mesh deployment create -g $resGroup --template-file .\arm-template.json

# get public ip address
$publicIp = az mesh network show -g $resGroup  --name todolistappNetwork --query "ingressConfig.publicIpAddress" -o tsv

# let's see if it's working
iwr http://$publicIp:20001

# get status of application
az mesh app show -g $resGroup --name todolistapp

# view logs for front-end container
az mesh code-package-log get -g $resGroup --application-name todolistapp --service-name WebFrontEnd --replica-name 0 --code-package-name WebFrontEnd

# see number of front end instances
az mesh service show -g $resGroup --name WebFrontEnd --app-name todolistapp --query "replicaCount"

# scale up with a fresh deployment
az mesh deployment create -g $resGroup --template-file .\arm-template.json --parameters .\m7-scale-front-end-params.json

# see number of front end instances
az mesh service show -g $resGroup --name WebFrontEnd --app-name todolistapp --query "replicaCount"

# delete everything
az group delete -n $resGroup -y