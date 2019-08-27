Import-Module -Name AzureADPreview
$creds = Get-AutomationPSCredential -Name 'AzureADPreviewAccount'
Connect-AzureAD -Credential $creds
get-azureadauditdirectorylogs