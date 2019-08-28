# store Azure AD audit Logs RunBook
PowerShell code to store Azure AD Audit Logs into an Azure Storage Account Table
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