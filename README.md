# Store Azure AD audit Logs RunBook

## Description: 

PowerShell code to create resource and execute runbook to store Azure AD Audit Logs into an Azure Storage Account Table

## Design
The PowerShell script will:
<ul>
<li> create resources:
   <ul>
      <li>a Storage Account, </li>
      <li>a Storage Table in the Storage Account,</li>
      <li>an Automation Account,</li>
      <li>a PowerShell RunBook in the Automation Account.</li>

   </ul>
</li>
<li>add credentials and variables to the Automation Account.</li>
<li>import the code of the runbook from a gist.</li>
<li>execute the runbook to import the Azure AD Audit logs from Azure Active Directory and store them into the Azure Storage Table.
</li>
<li>display the result of the runbook job.</li>
</ul>

## Prerequisites: 
To make this work you must:
<ul>
<li>Have access to an Azure tenant and to an Azure subscription of that tenant.</li>
<li>Have a Global Administrator account for that tenant.</li>
<li>Have the Azure AD Audit logs non empty (you can manually create user in Azure AD if needed or <a href="https://mosshowto.blogspot.com/2019/08/create-user-azure-ad-powershell.html">use this post to it using PowerShell</a>).</li>
<li>Have a local PowerShell environement with new Az module installed and working properly.</li>
</ul>

## Warning
<b>This is a tutorial or a proof of concept. Do not never, ever use this design in a real IT department</b>:
<ul>
<li>
This design uses the AzureADPreview module the use of which is not allowed for production matters.
</li>
<li>
This design uses the Global Administrator credentials in the runbook that is strictly a bad idea, because, in a real company, if a malicious people can have access to the runbook and change the code (that is quite easy) , this people could perform catastrophies regarding Azure environements in this company.  
</li>
</ul>