$tenantDomain = "" #type your tenant name here (contoso if contoso.onmicrosoft.com, lower case, letter and number only)
$location ="francecentral" #change for the location closer to your place if needed
$subscriptionId = "" #the Id of the subscription  where you want to create automation account and storage account ex : b50c6341-bf22-4c10-8d4d-34c9e4179522
$subscriptionName=""  #the name of the subscription where you want to create automation account and storage account
$resourceGroupName = "azureADAuditLogs"
$automationAccountName ="adlogs-automationAccount"
$automationCredentialsName = "azureADConnectAccount"
$storageAccountNameSuffix = "adlogs2" #increment the number each time you perform a new test (except if you delete the storage account after each test)
$storageaccountname = $tenantDomain + $storageAccountNameSuffix
$tableName = "azureADAuditLogs"
$runbookName = "exportAzureADAuditLogs"



Get-AzSubscription
Set-AzContext -Subscription $subscriptionId
Get-azcontext

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

New-AzAutomationCredential -Name  $automationCredentialsName -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Value (Get-Credential)

New-AzAutomationVariable -AutomationAccountName $automationAccountName -Name "subscriptionName" -Encrypted $False -Value $subscriptionName -ResourceGroupName $resourceGroupName
New-AzAutomationVariable -AutomationAccountName $automationAccountName -Name "resourceGroupName" -Encrypted $False -Value $resourceGroupName -ResourceGroupName $resourceGroupName
New-AzAutomationVariable -AutomationAccountName $automationAccountName -Name "storageAccountName" -Encrypted $False -Value $storageaccountname -ResourceGroupName $resourceGroupName
New-AzAutomationVariable -AutomationAccountName $automationAccountName -Name "automationCredentialsName" -Encrypted $False -Value $automationCredentialsName -ResourceGroupName $resourceGroupName
New-AzAutomationVariable -AutomationAccountName $automationAccountName -Name "tableName" -Encrypted $False -Value $tableName -ResourceGroupName $resourceGroupName



$StorageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageaccountname -Location $location -SkuName Standard_RAGRS -Kind StorageV2
$ctx = $storageAccount.Context

New-AzStorageTable -Name $tableName -Context $ctx
$runBookContentUri = "https://gist.githubusercontent.com/MarcCharmois/0054fc0e20f26afc3161d9397c16d083/raw/8ac0bf3a7d445aaba8a072c769591582acb83e9b/Store%2520Azure%2520AD%2520Audit%2520logs%2520Runbook%25201"
Invoke-WebRequest -Uri $runBookContentUri -OutFile 'C:\dev\Test-exportAzureadauditlogs.ps1'

$params = @{
    'Path'                  = 'C:\dev\Test-exportAzureadauditlogs.ps1'
    'Description'           = 'export Azure AD Audit logs in a Azure Storage Account Table'
    'Name'                  = $runbookName
    'Type'                  = 'PowerShell'
    'ResourceGroupName'     = $resourceGroupName
    'AutomationAccountName' = $automationAccountName
    'Published'             = $true
}
Import-AzAutomationRunbook @params

$job = Start-AzAutomationRunbook -Name $runbookName -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName

# Waiting for job completion
$timeCount = 0
do{
   #loop body instructions
   Start-Sleep -s 1
   $timeCount++
   Write-Output ("waited " + $timeCount + " second(s)")
   $job2 = Get-AzAutomationJob -JobId $job.JobId -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName
   if($job2.Status -ne "Completed"){
        Write-Output ("job status is " + $job2.Status + " and not completed")
   }else{
        Write-Output ("job status is " + $job2.Status + ". Writing Job information and  Output for checking...")
   }
}while($job2.Status -ne "Completed")
$job2 = Get-AzAutomationJob -JobId $job.JobId -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName
$job2
if($job2.Exception -eq $null){
    Write-Output ("job completed with no exceptions")
}else{
    Write-Output ("job exceptions: " + $job2.Exception)
}
# Full job output 
$jobOutPut = Get-AzAutomationJobOutput -AutomationAccountName $automationAccountName -Id $job.JobId -ResourceGroupName $resourceGroupName -Stream "Any" | Get-AzAutomationJobOutputRecord
$jobOutPut = ($jobOutPut | ConvertTo-Json) | ConvertFrom-Json
$index=0

foreach ($item in $jobOutPut){
    $index++
    Write-Output "---------------------------------"
    Write-Output ("output " + $index)
    Write-Output ($item.Value)
}