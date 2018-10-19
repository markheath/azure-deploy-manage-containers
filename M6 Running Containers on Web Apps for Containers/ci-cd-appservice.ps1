# get logged in to the azure cli
az login
az account show --query name -o tsv
az account set -s "MySubscription"

# create a resource group in our preferred location to use
$resourceGroup = "cicdappservice"
$location = "westeurope"
az group create -l $location -n $resourceGroup

Function Get-RandomString($length)
{
    $validChars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWZYZ".ToCharArray()
    Return -join ((1..$length) | ForEach-Object { $validChars | Get-Random | ForEach-Object {[char]$_} })
}


# create an app service plan to host
$planName="cicdappservice"
az appservice plan create -n $planName -g $resourceGroup -l $location --is-linux --sku S1

$acrName = "pluralsightacr"
$acrLoginServer = az acr show -n $acrName --query loginServer -o tsv
$dockerRepo = "$acrLoginServer/samplewebapp:v2"
# n.b. can't use anything but docker hub here
# so we have to arbitrarily pick a runtime --runtime "node|6.2" or a public image
$appName="cicd-$((Get-RandomString 4).ToLower())"
az webapp create -n $appName -g $resourceGroup --plan $planName -i "scratch"

$acrUserName = az acr credential show -n $acrName --query username -o tsv
$acrPassword = az acr credential show -n $acrName --query passwords[0].value -o tsv
# https://github.com/Azure/azure-cli/pull/3888/files - maybe don't need creds?
az webapp config container set -n $appName -g $resourceGroup -c "$acrLoginServer/samplewebapp:v2" -r "https://$acrLoginServer" -u $acrUserName -p $acrPassword

$site = az webapp show -n $appName -g $resourceGroup --query "defaultHostName" -o tsv
Start-Process http://$site

# create a staging slot (cloning from production slot's settings)
az webapp deployment slot create -g $resourceGroup -n $appName -s staging --configuration-source $appName

az webapp show -n $appName -g $resourceGroup -s staging --query "defaultHostName" -o tsv


# enable CD for the staging slot
az webapp deployment container config -g $resourceGroup -n $appName -s staging --enable-cd true

# get the webhook
$cicdurl = az webapp deployment container show-cd-url -s staging -n $appName -g $resourceGroup --query CI_CD_URL -o tsv

# to configure the webhook on an ACR registry
az acr webhook create --registry $acrName --name myacrwebhook01 --actions push --uri $cicdurl

# perform a slot swap
az webapp deployment slot swap -g $resourceGroup -n $appName --slot staging --target-slot production

# clean up
az group delete --name $resourceGroup --yes --no-wait