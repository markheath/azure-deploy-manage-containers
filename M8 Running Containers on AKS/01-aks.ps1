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

# 1. Create a resource group
$resourceGroup = "AKSDemo"
$location = "westeurope" # see valid regions at https://azure.microsoft.com/en-gb/global-infrastructure/services/?products=kubernetes-service
az group create -n $resourceGroup -l $location

# 3. Create our AKS Cluster (takes about 8 minutes)
$clusterName = "MarkAks"
# could also say --enable-addons monitoring
az aks create -g $resourceGroup -n $clusterName --node-count 1 --generate-ssh-keys

# 3b. to check it worked
az aks show -g $resourceGroup -n $clusterName

# check we have kubectl (should have if we've installed docker for windows)
kubectl version --short

# if not install the kubectl CLI (needs to be done from Administrator prompt)
# ends up putting it in on Windows C:\\Program Files (x86)\\kubectl.exe
### az aks install-cli
# we'll work round this by storing path to kubectl in a variable
### $env:Path = $env:Path + ";C:\Program Files (x86)"

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
kubectl apply -f sample-app.yaml

# example output:
# deployment.apps "samplebackend" created
# service "samplebackend" created
# deployment.apps "samplewebapp" created
# service "samplewebapp" created

# 2. find out where it is
kubectl get service samplewebapp --watch
# example output:
# NAME           TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
# samplewebapp   LoadBalancer   10.0.215.132   <pending>        8080:30984/TCP   6m
# .. later:
# samplewebapp   LoadBalancer   10.0.215.132   104.40.183.133   8080:30984/TCP   6m

# 3. launch app in browser (use IP address from previous command)
Start-Process http://52.232.105.209

# 4. run kubernetes dashboard
az aks browse -g $resourceGroup -n $clusterName


# BONUS
# we can scale the cluster
az aks scale -g $resourceGroup -n $clusterName --node-count 3

# let's have three replicas of our front end container
kubectl scale --replicas=3 deployment/samplewebapp

# check status
kubectl get pod

kubectl get deployment samplewebapp

# we can upgrade our app
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-app-update
kubectl set image deployment samplewebapp samplewebapp=markheath/samplewebapp:v2

kubectl get pod

# we can get logs
###kubectl logs <<podname>>

# n.b. updating if not using :latest
# https://stackoverflow.com/questions/33112789/how-do-i-force-kubernetes-to-re-pull-an-image

# we can upgrade kubernetes
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-upgrade-cluster

# we can attach disks / Azure file shares
# https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv

# deploy the example vote app
kubectl apply -f .\example-vote.yml
# change the vote deployment to 2 instances with eggs and bacon
kubectl apply -f .\example-vote-v2.yml
# delete
kubectl delete -f .\example-vote-v2.yml

# Clean up
az group delete --name $resourceGroup --yes --no-wait

