# get logged in to the azure cli
az login
az account show --query name -o tsv
az account set -s "MySubscription"

# create a resource group in our preferred location to use
$resourceGroup = "cicdappservice"
$location = "westeurope"
az group create -l $location -n $resourceGroup

# create an app service plan to host
$planName="cicdappservice"
az appservice plan create -n $planName -g $resourceGroup -l $location `
                          --is-linux --sku S1


# n.b. can't use anything but docker hub here
# so we have to arbitrarily pick a runtime --runtime "node|6.2" or a public image like scratch
$appName="cicd-pluralsight"
az webapp create -n $appName -g $resourceGroup --plan $planName -i "scratch"

$acrName = "pluralsightacr"
$acrLoginServer = az acr show -n $acrName --query loginServer -o tsv
$acrUserName = az acr credential show -n $acrName --query username -o tsv
$acrPassword = az acr credential show -n $acrName --query passwords[0].value -o tsv

# https://github.com/Azure/azure-cli/pull/3888/files - maybe don't need creds?
az webapp config container set -n $appName -g $resourceGroup `
                               -c "$acrLoginServer/samplewebapp:latest" `
                               -r "https://$acrLoginServer" `
                               -u $acrUserName -p $acrPassword

az webapp show -n $appName -g $resourceGroup --query "defaultHostName" -o tsv

# create a staging slot (cloning from production slot's settings)
az webapp deployment slot create -g $resourceGroup -n $appName `
                                 -s staging --configuration-source $appName

az webapp show -n $appName -g $resourceGroup -s staging --query "defaultHostName" -o tsv


# enable CD for the staging slot
az webapp deployment container config -g $resourceGroup -n $appName `
                                      -s staging --enable-cd true

# get the webhook
$cicdurl = az webapp deployment container show-cd-url -s staging `
                     -n $appName -g $resourceGroup --query CI_CD_URL -o tsv

# to configure the webhook on an ACR registry
az acr webhook create --registry $acrName --name myacrwebhook --actions push `
                      --uri $cicdurl

# push a new version of our app to the ACR
docker push pluralsightacr.azurecr.io/samplewebapp:latest

# perform a slot swap
az webapp deployment slot swap -g $resourceGroup -n $appName `
                               --slot staging --target-slot production

# clean up
az group delete --name $resourceGroup --yes --no-wait

# delete the webhook
az acr webhook delete --registry $acrName --name myacrwebhook