# MSExchangeDynamicDistroCreation
repository for the project to create dynamic distribution groups in exchange online powershell. 


This process should start with creating a DDG for the leader at VP level using the "CreateDynamicDistro.ps1" script. This will create a DDG comprised of just their reports.  --Be sure to change parameters as needed. 

Use "DDGPrintTeam" to export that DDG to a .csv containing all members of that DDG. 

Use "DDGFormat.ps1" to format the .csv in preperation of the next step. 

Finally use the "CreateDDG.ps1" script to create a dynamic distro for each member on the .csv, these groups will populate with each .csv members reports. 


