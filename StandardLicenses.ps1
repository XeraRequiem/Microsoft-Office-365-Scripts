<#	
	===========================================================================
	 Created by: Xera
	===========================================================================
	 Updates the services of 1 or more licenses to the standard set of services.
	 Takes in 2 text file locations or a single principal name. 
	 The user file contains a list of users with each user's name on a separate line.
	 The exception file contains a list of users in the same format that are not to be affected.
#>

param (
	#Location of list of users
	[Parameter(Mandatory = $false)]
	[System.String]$UsersFile,
							
	#Principal Name of User
	[Parameter(Mandatory = $false)]
	[System.String]$PrincipalName,						
	
	#Location of list of excepted users	
	[Parameter(Mandatory = $false)]
	[System.String]$ExceptionsFile,				
	
	#Include to standardize "Office 365 Enterprise E5" License
	[Parameter(Mandatory = $false)]
	[Switch]$E5,		
								
	#Include to standardize "Dynamics 365 for Customer Service" License
	[Parameter(Mandatory = $false)]
	[Switch]$CRMCustomer,									
	
	#Include to standardize "Dynamics 365 for Sales" License
	[Parameter(Mandatory = $false)]
	[Switch]$CRMSales,									
	
	#Include to standardize "Visio Pro for Office 365" License
	[Parameter(Mandatory = $false)]
	[Switch]$Visio,										
	
	#Include to standardize "Project Online Professional" License
	[Parameter(Mandatory = $false)]
	[Switch]$Project,									
	
	#Include to standardize "Skype for Business PSTN Domestic Calling" License
	[Parameter(Mandatory = $false)]
	[Switch]$PSTNDom,									
	
	#Include to standardize "Skype for Business PSTN International & Domestic Calling" License
	[Parameter(Mandatory = $false)]
	[Switch]$PSTNInt									
)

#List of standard enabled services under each license(License = Enabled Services)
$StandardServices = @{
	'ENTERPRISEPREMIUM' = 'FORMS_PLAN_E5', 'STREAM_O365_E5',  'FLOW_O365_P3', 'EQUIVIO_ANALYTICS', 'SWAY', 'ATP_ENTERPRISE', 'MCOEV', 'MCOMEETADV', 'BI_AZURE_P2', 'RMS_S_ENTERPRISE', 'YAMMER_ENTERPRISE', 'OFFICESUBSCRIPTION', 'MCOSTANDARD', 'SHAREPOINTENTERPRISE', 'SHAREPOINTWAC';
	'DYN365_ENTERPRISE_CUSTOMER_SERVICE' = 'SHAREPOINTWAC', 'DYN365_ENTERPRISE_CUSTOMER_SERVICE';
	'DYN365_ENTERPRISE_SALES' = 'SHAREPOINTWAC', 'DYN365_ENTERPRISE_SALES';
	'VISIOCLIENT' = 'VISIO_CLIENT_SUBSCRIPTION';
	'PROJECTPROFESSIONAL' = 'SHAREPOINTWAC', 'SHAREPOINTENTERPRISE', 'PROJECT_CLIENT_SUBSCRIPTION';
	'MCOPSTN1' = 'MCOPSTN1';
	'MCOPSTN2' = 'MCOPSTN2';
}

function standard ($License) {
	#Microsoft Online ID
	$TenantName = 'Company Microsoft Online ID Here'
	
	$SKU = "{0}:{1}" -f $TenantName, $License
	
	#List of all services
	$Services = (Get-MsolAccountSku | where { $_.AccountSkuId -eq $SKU }).ServiceStatus.ServicePlan.ServiceName

	#Services that should be enabled
	$EnabledServices = $StandardServices.Get_Item($License)
	
	#Remove enabled services from list of services
	$DisabledServices = $Services | where { $EnabledServices -notcontains $_ }

	#Create License option with list of Standard Disabled Services
	$Options = New-MsolLicenseOptions -AccountSkuId $SKU -DisabledPlan $DisabledServices
	
	foreach ($User in $Users) {
		Write-Host ($User + "`t" + $License)
		
		#Retrieve User's Licenses
		$UserLicenses = (Get-MsolUser -UserPrincipalName $User).Licenses.AccountSkuId
		
		if ($UserLicenses -contains $SKU) {
			Set-MsolUserLicense -UserPrincipalName $User -LicenseOptions $Options
        } else {
			Set-MsolUserLicense -UserPrincipalName $User -AddLicenses $SKU -LicenseOptions $Options
		}
	}
}

#Required module for accessing Microsoft Online
Import-Module MSOnline

#Service Account login information
$Username = 'Admin Account Username'
$Password = 'Admin Account Password'

#Create Login Credentials
$SecurePW = ConvertTo-SecureString $Password -AsPlainText -Force
$O365Cred = New-Object System.Management.Automation.PSCredential($Username, $SecurePW)

#Connect to Microsoft Online
Connect-MsolService -Credential $O365Cred

$Users = @()
if ($PSBoundParameters.ContainsKey('PrincipalName')) {
	$Users = $PrincipalName
} elseif ($PSBountParameters.ContainsKey('UsersFile')) {
	$Users = Get-Content -Path $UsersFile
} else {
	$Users = (Get-MsolUser -all).UserPrincipalName
}

if ($PSBoundParameters.ContainsKey('ExceptionsFile')) {
	#List of Users to be Excepted 
	$Exceptions = Get-Content -Path $ExceptionsFile
	
	#Remove excepted users from list of users
	$Users = $Users | where { $Exceptions -notcontains $_ }
}

#Standardize E5 License
if ($E5) {
	standard 'ENTERPRISEPREMIUM'
}

#Standardize One of the CRM licenses (Both can't be enabled)
if ($CRMCustomer) {
	standard 'DYN365_ENTERPRISE_CUSTOMER_SERVICE'
} elseif ($CRMSales) {
	standard 'DYN365_ENTERPRISE_SALES'
}

#Standardize Visio License
if ($Visio) {
	standard 'VISIOCLIENT'
}

#Standardize Project License
if ($Project) {
	standard 'PROJECTPROFESSIONAL'
}

#Standardize PSTN Domestic or International License
if ($PSTNDom) {
	standard 'MCOPSTN1'
} elseif ($PSTNInt) {
	standard 'MCOPSTN2'
}



# SIG # Begin signature block
# MIITigYJKoZIhvcNAQcCoIITezCCE3cCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgU6pR9BaZYqrq/o7ViJso5sn
# K/aggg3rMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BJ8wggOHoAMCAQICEhEh1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQUFADBS
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UE
# AxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAeFw0xNjA1MjQwMDAw
# MDBaFw0yNzA2MjQwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8wHQYDVQQKExZHTU8g
# R2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxTaWduIFRTQSBmb3Ig
# TVMgQXV0aGVudGljb2RlIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal+oTDYUDFRrVZUjtC
# oi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1AcjzyCXenSZKX1GyQ
# oHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFFWbIub2Jd4NkZrItX
# nKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7spTj1Tk7Om+o/SWJMV
# TLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5crCpGTkqUPqp0Dw6
# yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAOBgNVHQ8BAf8EBAMC
# B4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6
# Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIuY3JsMFQGCCsGAQUF
# BwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNv
# bS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0OBBYEFNSihEo4Whh/
# uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0hZuw3WrWFKnBMA0G
# CSqGSIb3DQEBBQUAA4IBAQCPqRqRbQSmNyAOg5beI9Nrbh9u3WQ9aCEitfhHNmmO
# 4aVFxySiIrcpCcxUWq7GvM1jjrM9UEjltMyuzZKNniiLE0oRqr2j79OyNvy0oXK/
# bZdjeYxEvHAvfvO83YJTqxr26/ocl7y2N5ykHDC8q7wtRzbfkiAD6HHGWPZ1BZo0
# 8AtZWoJENKqA5C+E9kddlsm2ysqdt6a65FDT1De4uiAO0NOSKlvEWbuhbds8zkSd
# wTgqreONvc0JdxoQvmcKAjZkiLmzGybu555gxEaovGEzbM9OuZy5avCfN/61PU+a
# 003/3iCOTpem/Z8JvE3KGHbJsE2FUPKA0h0G9VgEB7EYMIIFLDCCBBSgAwIBAgII
# Sn2Fj+tqMVIwDQYJKoZIhvcNAQELBQAwgbQxCzAJBgNVBAYTAlVTMRAwDgYDVQQI
# EwdBcml6b25hMRMwEQYDVQQHEwpTY290dHNkYWxlMRowGAYDVQQKExFHb0RhZGR5
# LmNvbSwgSW5jLjEtMCsGA1UECxMkaHR0cDovL2NlcnRzLmdvZGFkZHkuY29tL3Jl
# cG9zaXRvcnkvMTMwMQYDVQQDEypHbyBEYWRkeSBTZWN1cmUgQ2VydGlmaWNhdGUg
# QXV0aG9yaXR5IC0gRzIwHhcNMTYwNDE1MjEwMzM4WhcNMTkwNDE1MjEwMzM4WjBu
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHU2Vh
# dHRsZTEbMBkGA1UEChMSTWNLaW5zdHJ5IENvLiwgTExDMRswGQYDVQQDExJNY0tp
# bnN0cnkgQ28uLCBMTEMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCZ
# Qqlk7T4SZfB4wvH9yXXH4WnRBh7Zjak3CXk/3qzL3Y3P8lZAG1UKOAwT4J9JNAfl
# R3ky1tOOupt9m9TofBIpWXSBtFmR2Ai2NgtYndUNl6Up7HetubDCIn/kK0ajg9qd
# g8sh+OSwCl9dZDA4nh2uFUcIm2AMkVmZrHlR4naTcnDTd41TNZTdHkNJpQG86Ah0
# wuW+ltqU7duYuU4P0cRVyUcMu+ngox1Uy+BwiX/Nfs++W8xHlqiLcdhSNSKdo3JR
# bM8gXWnB+96aJ5/aL4BpegWDGSM1G/8xgLXr9hHy6fTYAOm/djlSKuEROhCAukGr
# wQSE2gAtzkCHthinezUdAgMBAAGjggGFMIIBgTAMBgNVHRMBAf8EAjAAMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDA1BgNVHR8ELjAsMCqgKKAm
# hiRodHRwOi8vY3JsLmdvZGFkZHkuY29tL2dkaWcyczUtMS5jcmwwXQYDVR0gBFYw
# VDBIBgtghkgBhv1tAQcXAjA5MDcGCCsGAQUFBwIBFitodHRwOi8vY2VydGlmaWNh
# dGVzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvMAgGBmeBDAEEATB2BggrBgEFBQcB
# AQRqMGgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmdvZGFkZHkuY29tLzBABggr
# BgEFBQcwAoY0aHR0cDovL2NlcnRpZmljYXRlcy5nb2RhZGR5LmNvbS9yZXBvc2l0
# b3J5L2dkaWcyLmNydDAfBgNVHSMEGDAWgBRAwr0njsw0gzCiM9f7bLPwtCyAzjAd
# BgNVHQ4EFgQUk93pM4DzXTsE+jgTx8VLJ5PIEcEwDQYJKoZIhvcNAQELBQADggEB
# ABMWPm6I3LGxuDci+FYSEIT13HqAg+jF/+KNw1WJ1+BvWqCWA7PoRWWjNLnyPAwD
# lJJfQdfi9W0VXFOavd7jixdAlaxRfz8kbVBUwx7iIrba/7B9QkqeKyMLEvLBwX1f
# VI7wwgRXyAGVvKzB+czuqjqqFrRM2m0Dy4TtpmSUtR+KeEVeO/ffPbGwgZSZn2rO
# M9GcoI+DwWmWYjxr9CqEF2QRVf3z9w2OBrPLBir5a/ldLxJvUssg4BOyHYFPSGvR
# mbjBeZhg/KjfXe+GDxc/j4jXMcSwxg55PVtW+oON6Fv/KVc4sxDOwsTvRaG8eL31
# HkcYbr+cmaoJSDMhEuFkxDExggUJMIIFBQIBATCBwTCBtDELMAkGA1UEBhMCVVMx
# EDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAYBgNVBAoT
# EUdvRGFkZHkuY29tLCBJbmMuMS0wKwYDVQQLEyRodHRwOi8vY2VydHMuZ29kYWRk
# eS5jb20vcmVwb3NpdG9yeS8xMzAxBgNVBAMTKkdvIERhZGR5IFNlY3VyZSBDZXJ0
# aWZpY2F0ZSBBdXRob3JpdHkgLSBHMgIISn2Fj+tqMVIwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FGkZifk8WUoOt38HAyXdlTbvyOGrMA0GCSqGSIb3DQEBAQUABIIBAF3BxsPeRwFx
# BBUzWjFO79Yyl9GdzW1BRuPEguAFdzFPQgWMhKDM8w6+zjgN0Hp28GMXzAtSy6Ca
# TDIgqP05MA+7wlR/gPzJre0yJNsrUNEvfE8OraLtBZTJ4lhdpmyHCQtWtRU3Y0uQ
# ODhy4eHnpPU5n83NEFGSh6oJuqK9jr5d/YBrqaop+Fb6hZ7OxSJ8cisk0SV4t9Sf
# UoqsAD5eThY+yHptAe++LlyMpWn0RDH4DRkKLRg4gVjzBDKpkTULKb9tRyKd71rx
# qo0DDWktmQ1nnmVy93P8iCRbhGySy764sWjZlTfORbqo1BO0C6twgtcwg0v8EDdN
# 2Q+OiHJfgkahggKiMIICngYJKoZIhvcNAQkGMYICjzCCAosCAQEwaDBSMQswCQYD
# VQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UEAxMfR2xv
# YmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMgISESHWmadklz7x+EJ+6RnMU0EU
# MAkGBSsOAwIaBQCggf0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG
# 9w0BCQUxDxcNMTcwODE4MTQyOTMyWjAjBgkqhkiG9w0BCQQxFgQUKp+Ou9lKt0MS
# EeKm2kQX5dq3EfIwgZ0GCyqGSIb3DQEJEAIMMYGNMIGKMIGHMIGEBBRjuC+rYfWD
# kJaVBQsAJJxQKTPseTBsMFakVDBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xv
# YmFsU2lnbiBudi1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcg
# Q0EgLSBHMgISESHWmadklz7x+EJ+6RnMU0EUMA0GCSqGSIb3DQEBAQUABIIBACxy
# 5uKtgjD5xly3r3khl4IGI1fMrd/rVS//l/aqi5H8zGtjXcXQ7JZYjN6i3nKeKq8c
# Y6e8oAKayhiIdg7fYYTR1/PzYDHGGCHLtltIfCAXhJx8ajCl42AOA2JlVfpS8Cl6
# hwdK2kPKvSljJd8usLwR1McKirRdd/Yd9AcL0rlLTCpFXnUCHYGutAZYeyPmnxty
# FEWsN0btOVSTRDxTQQ3pA/NglFBruIYF7tB9dOkhz3iCO9RH2jIfo6qgIv7KiG7y
# UgdK//iS9nRu6K71b5v0fzEDSeHXNaceCsaZ1jlFD+cNEIxEEbXEiNV9QLCZXx9N
# 253twZSMumPEQNNQJjQ=
# SIG # End signature block
