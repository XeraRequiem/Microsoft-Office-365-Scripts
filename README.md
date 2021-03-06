# Microsoft Office 365 Scripts
Standardizes the services under specific licenses. If the user doesn’t have a license, then the user is given that license with the standard set of services enabled. Any combination of the 8 licenses can be standardized by including the corresponding switches. Standard set of services is given by McKinstry IT and is embedded within the script. To change the standard, change the hash table of enabled services within the script. Note: Only 1 CRM license and 1 PSTN license can be enabled at a time.

To Use Script:
1. Open script in any text editor.
2. Replace the Username and Password with the Username and Password of your Admin account.
3. Replace TenantID with your company's Microsoft Online Id.
4. (Recommended) Replace each license's list of enabled services with your comapany's standard lists.
5. Execute script via PowerShell

# Output
Outputs errors and the principal name of the user being standardized to console in real time. No output file.

# Parameters
	-UsersFile 
		Type: String
		Input: Path to text file containing the list of principal names that will have their license standardized.
		Users without the license will have the license enabled before standardizing the services. Text file
		should be formatted so each name is separated by a new line. Cannot be used with PrincipalName parameter.
		
	-PrincipalName 
		Type: String
		Input: Principal name of the user to be affected by the script. Do not include if UsersFile parameter is set.
		Cannot be used with UsersFile parameter.
		
	-ExceptionsFile 
		Type: String
		Input: Path to text file containing list of principal names that should not have their license standardized.
		File must be formatted so each name is separated by a new line. Requires UsersFile parameter to be included.
	
	-E1
		Type: Switch
		Input: None
		Include to standardize services under Enterprise E1 license.
	-E5 
		Type: Switch
		Input: None
		Include to standardize services under Enterprise E5 license.
	
	-CRMCustomer 
		Type: Switch
		Input: None
		Include to standardize services under Dynamics 365 for Customer Service license.
	
	-CRMSales 
		Type: Switch
		Input: None
		Include to standardize services under Dynamics 365 for Sales license.
	
	-Visio 
		Type: Switch
		Input: None
		Include to standardize services under Visio Pro for Office 365 license.
	
	-Project 
		Type: Switch
		Input: None
		Include to standardize services under Project Professional license.
	
	-PSTNDom 
		Type: Switch
		Input: None
		Include to standardize services under Skype for Business PSTN Domestic Calling license.
	
	-PSTNInt 
		Type: Switch
		Input: None
		Include to standardize services under Skype for Business PSTN International & Domestic Calling license.

