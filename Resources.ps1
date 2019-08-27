$location ="francecentral"
$resourceGroupName = "azureADAuditLogs"
Get-AzSubscription
Set-AzContext -Subscription b50c6341-bf22-4c10-8d4d-34c9e4179513
get-azcontext
$automationAccountName ="ADLogs-automationAccount"
New-AzResourceGroup -Name $resourceGroupName -location $Location 
New-AzAutomationAccount -ResourceGroupName $resourceGroupName -Name $automationAccountName -Location $Location -Plan Free

$ModuleADPreview = "AzureADPreview"
$uriModuleADPreview = (Find-Module $ModuleADPreview).RepositorySourceLocation + 'package/' + $ModuleADPreview
$uriModuleADPreview
New-AzAutomationModule -Name $ModuleADPreview -ContentLinkUri $uriModuleADPreview -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName

$ModuleStorageTable = "AzureRmStorageTable"
$uriModuleStorageTable = (Find-Module $ModuleStorageTable).RepositorySourceLocation + 'package/' + $ModuleStorageTable +'/1.0.0.23'
$uriModuleStorageTable
New-AzAutomationModule -Name $ModuleStorageTable -ContentLinkUri $uriModuleStorageTable -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName

New-AzAutomationCredential -Name  'AzureADConnectAccount' -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Value (Get-Credential)
$tenantDomain = "charmoisdev"
$storageaccountname = $tenantDomain + "adlogs1"
$storageaccountname
$StorageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageaccountname -Location $location -SkuName Standard_RAGRS -Kind StorageV2
$ctx = $storageAccount.Context
$tableName = "AzureADAuditLogs"
New-AzStorageTable –Name $tableName –Context $ctx
$runBookContentUri = "https://gist.githubusercontent.com/MarcCharmois/0054fc0e20f26afc3161d9397c16d083/raw/cf2d51da869c01be1f1df4277282029c94529aeb/Store%2520Azure%2520AD%2520Audit%2520logs%2520Runbook%25201"
Invoke-WebRequest -Uri $runBookContentUri -OutFile 'C:\dev\Test-exportAzureadauditlogs.ps1'
$RBName = "exportAzureADAuditLogs"
$params = @{
    'Path'                  = 'C:\dev\Test-exportAzureadauditlogs.ps1'
    'Description'           = 'export Azure AD Audit logs in a Azure Storage Account Table'
    'Name'                  = $RBName
    'Type'                  = 'PowerShell'
    'ResourceGroupName'     = $resourceGroupName
    'AutomationAccountName' = $automationAccountName
    'Published'             = $true
}
Import-AzAutomationRunbook @params