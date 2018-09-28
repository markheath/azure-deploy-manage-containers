# PART 1 -Getting Started with Azure CLI
#
# 1. Login:
az login
#
# 2. See which subscription is selected
az account show --query name -o tsv
#
# 3. See which subscriptions are available
az account list -o table
#
# 4. Select the subscription you want to use
az account set -s "MySub"


# PART 2 - Getting Started with AKS
# https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
# 
# 1. Enable AKS Preview on this subscription
az provider register -n Microsoft.ContainerService

# 2. Create a resource group
$resourceGroup = "AKSDemo"
$location = "westeurope" # valid options are currently 'eastus,westeurope,centralus,canadacentral,canadaeast'
az group create --name $resourceGroup --location $location

# 3. Create our AKS Cluster (takes about 8 minutes)
$clusterName = "MarkAks"
az aks create -g $resourceGroup -n $clusterName --node-count 1 --generate-ssh-keys

# 3b. to check it worked
az aks show -g $resourceGroup -n $clusterName

# 4. install the kubectl CLI (needs to be done from Administrator prompt)
# ends up putting it in on Windows C:\\Program Files (x86)\\kubectl.exe
az aks install-cli
# we'll work round this by storing path to kubectl in a variable
#$kubectl = "C:\\Program Files (x86)\\kubectl.exe"
$env:Path = $env:Path + ";C:\Program Files (x86)"

# 5. Get credentials and set up for kubectl to use
az aks get-credentials -g $resourceGroup -n $clusterName

# 6. Check we're connected
kubectl get nodes

# example output:
#NAME                       STATUS    ROLES     AGE       VERSION
#aks-nodepool1-29826014-0   Ready     agent     59m       v1.7.7

# PART 3 - Running an app on AKS
# https://github.com/Azure-Samples/azure-voting-app-redis

# 1. deploy the app
kubectl create -f azure-vote.yaml

# example output:
# deployment "azure-vote-back" created
# service "azure-vote-back" created
# deployment "azure-vote-front" created
# service "azure-vote-front" created

# 2. find out where it is
kubectl get service azure-vote-front --watch
# example output:
# NAME               TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
# azure-vote-front   LoadBalancer   10.0.228.33   <pending>     80:30182/TCP   22s
# .. later:
# azure-vote-front   LoadBalancer   10.0.228.33   52.232.105.209   80:30182/TCP   2m

# 3. launch app in browser (use IP address from previous command)
Start-Process http://52.232.105.209

# 4. run kubernetes dashboard
az aks browse -g $resourceGroup -n $clusterName


# BONUS
# we can scale the cluster
az aks scale -g $resourceGroup -n $clusterName --node-count 3

# let's have three replicas of our front end container
kubectl scale --replicas=3 deployment/azure-vote-front

# check status
kubectl get pod

# we can upgrade our app
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-app-update
kubectl set image deployment azure-vote-front azure-vote-front=markheath/azure-vote-front:v2

kubectl get pod

# we can upgrade kubernetes
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-upgrade-cluster

# we can attach disks / Azure file shares
# https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv
# https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv


# Clean up
az group delete --name $resourceGroup --yes --no-wait



## updating

## creating the update
git clone https://github.com/Azure-Samples/azure-voting-app-redis.git
cd azure-voting-app-redis
# switch to linux containers
docker-compose up -d
Start-Process http://localhost:8080
docker images
docker-compose stop
docker-compose down

# push the image
docker login
docker tag azure-vote-front markheath/azure-vote-front:v1
docker push markheath/azure-vote-front:v1

# update azure-vote-all-in-one-redis.yaml to set container to markheath/azure-vote-front:v1
kubectl create -f azure-vote-all-in-one-redis.yaml
kubectl get service azure-vote-front --watch

# update the config file
docker-compose build
docker tag azure-vote-front markheath/azure-vote-front:v2

## deploying the update

az aks scale --resource-group=$resourceGroup --name=$clusterName --node-count 3
kubectl scale --replicas=3 deployment/azure-vote-front

# see current pod state
kubectl get pod

# perform the update
kubectl set image deployment azure-vote-front azure-vote-front=markheath/azure-vote-front:v2

# monitor the update
kubectl get pod