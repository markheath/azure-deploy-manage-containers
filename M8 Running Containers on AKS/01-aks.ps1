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
### az aks install-cli
# update path to be able to find kubectl:
### $env:path += ';C:\Users\mheath\.azure-kubectl'

# 5. Get credentials and set up for kubectl to use (may need to confirm to overwrite existing kubeconfig entries)
az aks get-credentials -g $resourceGroup -n $clusterName

# 6. Check we're connected
kubectl get nodes

# example output:
#NAME                       STATUS    ROLES     AGE       VERSION
#aks-nodepool1-29826014-0   Ready     agent     59m       v1.12.8

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
Start-Process http://52.232.105.209:8080

# 4. see the status of our pods
kubectl get pod

# 5. view logs from a pod
# kubectl logs <<podname>>

# PART 3 - SCALING
# we can scale the cluster
az aks scale -g $resourceGroup -n $clusterName --node-count 3

# see the nodes
kubectl get nodes

# deploy the example vote app
kubectl apply -f .\example-vote.yml

# watch for the public ip addresses of the vote and result services
kubectl get service --watch

# change the vote deployment to 3 replicas with eggs and bacon
kubectl apply -f .\example-vote-v2.yml

# enable the kube-dashboard
az aks enable-addons --addons kube-dashboard -g $resourceGroup -n $clusterName

# run kubernetes dashboard (now takes you to Azure Portal)
az aks browse -g $resourceGroup -n $clusterName

### BONUS STEPS
# how to directly scale to three replicas of our front end container
kubectl scale --replicas=3 deployment/samplewebapp

# how to upgrade a container directly
kubectl set image deployment samplewebapp samplewebapp=markheath/samplewebapp:v2

# delete an app deployed with kubectl apply
kubectl delete -f .\example-vote-v2.yml

# deploy a second instance to another namespace
kubectl create namespace staging

kubectl apply -f .\example-vote.yml -n staging
kubectl get service -n staging

# for if you are using the newer vote service which doesn't expose
# external services
kubectl port-forward -n vote service/vote 5000:5000
kubectl port-forward -n vote service/result 5001:5001


# Clean up
az group delete -n $resourceGroup --yes --no-wait

