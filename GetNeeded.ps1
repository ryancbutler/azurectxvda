param(

	[string]$azurelocation = 'centralus',
	[string]$app_password = 'mysupersecrect',
	[string]$resourcegroup = 'packer'
)

Login-AzureRmAccount
$azuresub = Get-AzureRmSubscription | Out-GridView -Passthru
Select-AzureRmSubscription -SubscriptionId $azuresub.id

New-AzureRmResourceGroup -Name $resourcegroup -Location $azurelocation -Verbose

$azurestorage = New-AzureRmStorageAccount -ResourceGroupName $resourcegroup -Name ($resourcegroup + $(Get-Random)) -SkuName Standard_GRS -Location $azurelocation -Verbose

$SecureStringPassword = ConvertTo-SecureString -String $app_password -AsPlainText -Force
$app = New-AzureRmADApplication -DisplayName $resourcegroup -HomePage http://localhost -IdentifierUris http://localhost -Password $SecureStringPassword -Verbose

$spn = New-AzureRmADServicePrincipal -DisplayName ("$resourcegroup + SPN") -ApplicationId $app.ApplicationId -Verbose

Start-Sleep -Seconds 20
$roleassignment = New-AzureRmRoleAssignment -ApplicationId $spn.ApplicationId -RoleDefinitionName Owner -Scope ("/subscriptions/$($azuresub.id)") -Verbose

$result = @{
	SubscriptionID = "$($azuresub.SubscriptionId)"
	TenantID = "$($azuresub.TenantId)"
	ClientID = "$($app.ApplicationId)"
	client_secret = $app_password
	resource_group_name = $resourcegroup
	storage_account = "$($azurestorage.StorageAccountName)"
}

$result | Format-Table -AutoSize
