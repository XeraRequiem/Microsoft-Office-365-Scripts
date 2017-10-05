# Microsoft Office 365 Scripts
PowerShell script for updating the services of Office 365 Licenses.

To Use Script:
1. Open script in any text editor.
2. Replace the Username and Password with the Username and Password of your Admin account.
3. Replace TenantID with your company's Microsoft Online Id.
4. (Recommended) Replace each license's list of enabled services with your comapany's standard lists.
5. Execute script via PowerShell

The script can be used to update the enabled services of a single user, a list of users, or all users registered under company's Microsoft Id.

# Parameters
	-UsersFil
		Type: String
		Input: Path to text file containing the list of principal names that will have their license standardized.
		Users without the license will have the license enabled before standardizing the services. Text file
		should be formatted so each name is separated by a new line. Cannot be used with PrincipalName parameter.
		
	-ExceptionsFile
		Type: String
	Input: Path to text file containing list of principal names that should not have their license standardized.
	File must be formatted so each name is separated by a new line.
	
	-PrincipalName
		Type: String
	Input: Principal name of the user that will have their license standardized.
	Cannot be used with UsersFile parameter.
