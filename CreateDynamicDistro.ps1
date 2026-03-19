#use the below commands from the exchange cloud powershell. 

#connect to exchange online
Connect-ExchangeOnline

#Create the distro, be sure to replace the placeholder names↓
New-DynamicDistributionGroup -Name "TeamNameDynamic" -RecipientFilter "(Manager -eq '$((Get-User -Identity "user.name@domain.com").DistinguishedName)') -and (RecipientTypeDetails -eq 'UserMailbox')"

#use this to verify. it will return the users in the distro. 
Get-Recipient -RecipientPreviewFilter (Get-DynamicDistributionGroup -Identity "teamNameDynamic").RecipientFilter | Select-Object DisplayName |sort-object displayname
