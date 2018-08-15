param (

[string]$azurelocation = 'centralus',
[string]$app_password = 'mysupersecrect',
[string]$subscription_ID = "SUBID"

)

Login-AzureRmAccount
$azuresub = Get-AzureRmSubscription -SubscriptionId $subscription_ID
Select-AzureRmSubscription -SubscriptionID $subscription_ID

New-AzureRmResourceGroup -Name $resourcegroup -Location $azurelocation -Verbose

$azurestorage = New-AzureRmStorageAccount -ResourceGroupName $resourcegroup -Name ($resourcegroup + $(Get-Random)) -SkuName Standard_GRS -Location $azurelocation -Verbose

$SecureStringPassword = ConvertTo-SecureString -String $app_password -AsPlainText -Force
$app = New-AzureRmADApplication -DisplayName $resourcegroup -HomePage http://localhost -IdentifierUris http://localhost -Password $SecureStringPassword -Verbose

$spn = New-AzureRmADServicePrincipal -DisplayName ("$resourcegroup + SPN") -ApplicationId $app.ApplicationId -Verbose

Start-Sleep -Seconds 10
$roleassignment = New-AzureRmRoleAssignment -ApplicationId $spn.ApplicationId -RoleDefinitionName Owner -Scope ("/subscriptions/$subscription_ID") -Verbose

$result = @{SubscriptionID="$($azuresub.SubscriptionId)"; TenantID = "$($azuresub.TenantId)"; ClientID = "$($app.ApplicationId)"; client_secret = $app_password; resource_group_name = $resourcegroup; storage_account = "$($azurestorage.StorageAccountName)"}
$result|ft -AutoSize