Import-Module -Name AzureADPreview
#Get the credentials encrypted by script
$automationCredentialsName =  Get-AutomationVariable -Name "automationCredentialsName"
$creds = Get-AutomationPSCredential -Name $automationCredentialsName

#Connect to Azure AD
Connect-AzureAD -Credential $creds
#Get Azure AD Audit Logs
$AuditLogs = get-azureadauditdirectorylogs

#Connect to Azure tenant
Add-AzureRMAccount -Credential $creds
#Set the storage account subscription
$subscriptionName = Get-AutomationVariable -Name 'subscriptionName'
Select-AzureRMSubscription -subscriptionName $subscriptionName
#Get key to storage account
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$storageAccountName = Get-AutomationVariable -Name 'storageAccountName'
$acctKeys = (Get-AzureRmStorageAccountKey -Name $storageAccountName -ResourceGroupName $resourceGroupName)
$acctKey = $acctKeys.Key1
#Set the storage context
$storageContext = New-AzureStorageContext -StorageAccountName storageAccountName -StorageAccountKey $acctKey
#Get the storage table
$tableName = Get-AutomationVariable -Name "tableName"
$storageTable = Get-AzureStorageTable -Name $tableName -Context $storageContext
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