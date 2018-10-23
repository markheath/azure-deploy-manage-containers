# https://github.com/Azure-Samples/service-fabric-mesh/blob/master/templates/todolist/mesh_rp.windows.json
# https://docs.microsoft.com/en-us/azure/service-fabric-mesh/service-fabric-mesh-tutorial-template-deploy-app
# https://github.com/Azure-Samples/service-fabric-mesh/tree/master/src/todolistapp

# check we are using the right subscription
az account show --query name -o tsv

# check if the extension we need is available
az extension list -o table
# to install
az extension add --name mesh
# to upgrade
az extension update --name mesh

# create a resource group
$resGroup = "ServiceFabricMeshTest"
az group create -n $resGroup -l "westeurope"

# deploy the mesh application
$templateFile = ".\sfmesh-windows.json"
az mesh deployment create -g $resGroup --template-file $templateFile

# should result in a message like:
#> application sampleapp has been deployed successfully on network sampleappNetwork with public ip address 13.94.227.208
#> To recieve additional information run the following to get the status of the application deployment.
#> az mesh app show --resource-group ServiceFabricMeshTest --name sampleapp

# get public ip address
$networkName = "sampleappNetwork"
$publicIp = az mesh network show -g $resGroup --name $networkName --query "ingressConfig.publicIpAddress" -o tsv

# let's see if it's working
Start-Process http://$publicIp

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
az mesh deployment create -g $resGroup --template-file $templateFile --parameters .\scale-front-end-params.json
# often seems to fail (even though replicas are created) with error like
# Unable to edit or replace deployment 'sfmesh-windows': previous deployment from '10/23/2018 12:55:17 PM' is still active (expiration time is '10/30/2018 12:55:06 PM'). Please see https://aka.ms/arm-deploy for usage details.

# see number of front end instances
az mesh service show -g $resGroup --name $frontEndServiceName --app-name $appName --query "replicaCount"

# see summary of services
az mesh service list -g $resGroup --app-name $appName -o table

# delete everything
az group delete -n $resGroup -y