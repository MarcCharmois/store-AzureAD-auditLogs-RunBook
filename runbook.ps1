Import-Module -Name AzureADPreview
#Get the credentials encrypted by script
$creds = Get-AutomationPSCredential -Name 'AzureADConnectAccount'

#Connect to Azure AD
Connect-AzureAD -Credential $creds
#Get Azure AD Audit Logs
$AuditLogs = get-azureadauditdirectorylogs

#Connect to Azure tenant
Add-AzureRMAccount -Credential $creds
#Set the storage account subscription
Select-AzureRMSubscription -subscriptionName "Admin"
#Get key to storage account
$acctKeys = (Get-AzureRmStorageAccountKey -Name "charmoisdevadlogs1" -ResourceGroupName "azureADAuditLogs")
$acctKey = $acctKeys.Key1
#Set the storage context
$storageContext = New-AzureStorageContext -StorageAccountName "charmoisdevadlogs1" -StorageAccountKey $acctKey
#Get the storage table
$tableName = "AzureADAuditLogs"
$storageTable = Get-AzureStorageTable –Name $tableName –Context $storageContext
$storageTable
write-output $AuditLogs
foreach( $operation in $AuditLogs){
    $partitionKey1 = "AD Audit Logs"
    $rowKey = $operation.id

# add rows 
    try{
        Add-StorageTableRow `
            -table $storageTable `
            -partitionKey $partitionKey1 `
            -rowKey $rowKey -property @{"value"=($operation | convertto-Json)}
    }catch{
        write-output $_.Exception
    }
}