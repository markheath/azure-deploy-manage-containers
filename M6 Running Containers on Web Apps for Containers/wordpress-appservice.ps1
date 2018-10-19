# in this demo we run a wordpress site in linux container mode

# get logged in to the azure cli
az login
az account show --query name -o tsv
az account set -s "MySubscription"

# create a resource group in our preferred location to use
$resourceGroup = "wordpressappservice"
$location = "westeurope"
az group create -l $location -n $resourceGroup

# create an app service plan to host
$planName="wordpressappservice"
az appservice plan create -n $planName -g $resourceGroup -l $location --is-linux --sku S1

# create a MySql database
# https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli
Function Get-RandomString($length)
{
    $validChars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWZYZ".ToCharArray()
    Return -join ((1..$length) | ForEach-Object { $validChars | Get-Random | ForEach-Object {[char]$_} })
}

$mysqlServerName = "mysql-$((Get-RandomString 4).ToLower())"
$adminUser = "wpadmin"
$adminPassword = Get-RandomString 20
# supported mysql versions: https://docs.microsoft.com/en-us/azure/mysql/concepts-supported-versions
# n.b. location is required for this command
# this wordpress demo also requires SSL enforcement to be disabled
az mysql server create -g $resourceGroup -n $mysqlServerName `
            --admin-user $adminUser --admin-password $adminPassword `
            -l $location `
            --ssl-enforcement Disabled `
            --sku-name GP_Gen4_2 --version 5.7

# open the firewall (use 0.0.0.0 to allow all Azure traffic for now)
az mysql server firewall-rule create -g $resourceGroup `
    --server $mysqlServerName --name AllowAppService `
    --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# create a new webapp based on our DockerHub image
$appName="wordpress-$((Get-RandomString 4).ToLower())"
$dockerRepo = "wordpress" # https://hub.docker.com/r/_/wordpress/
az webapp create -n $appName -g $resourceGroup --plan $planName -i $dockerRepo

$wordpressDbHost = (az mysql server show -g $resourceGroup -n $mysqlServerName --query "fullyQualifiedDomainName" -o tsv)

# configure settings
az webapp config appsettings set `
    -n $appName -g $resourceGroup --settings `
    WORDPRESS_DB_HOST=$wordpressDbHost `
    WORDPRESS_DB_USER="$adminUser@$mysqlServerName" `
    WORDPRESS_DB_PASSWORD="$adminPassword"

# launch in a browser
$site = az webapp show -n $appName -g $resourceGroup --query "defaultHostName" -o tsv
Start-Process https://$site

# scale up app service
az appservice plan update -n $planName -g $resourceGroup --number-of-workers 3


# clean up
az group delete --name $resourceGroup --yes --no-wait