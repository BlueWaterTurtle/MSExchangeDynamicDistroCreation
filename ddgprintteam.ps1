#Use this script to export a .csv containing the DDG's member Email addresses and names. this is then referenced in the "createDDG.ps1" script. Currently the .csv still needs to be manually formated/checked beforehand. 


$ddg = Get-DynamicDistributionGroup -Identity "TeamKnameDynamic" #change the team name as needed


$outPath = Join-Path $HOME "Teamname-members.csv"  


Get-Recipient -RecipientPreviewFilter $ddg.RecipientFilter |
  ForEach-Object { Get-User -Identity $_.Identity } |
  Sort-Object DisplayName |
  Select-Object DisplayName, UserPrincipalName |
  Export-Csv -Path $outPath -NoTypeInformation

$outPath