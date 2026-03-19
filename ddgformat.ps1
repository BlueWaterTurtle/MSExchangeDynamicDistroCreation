#use this to reformat the .csv export from exchange online. This script should be used on the .csv exported from exchange before using them to create DDG's as this will simply change the users name to the team name. for exampel "John Smith" would convert to "TeamSmithDynamic" this is the current naming convention I'm using. 


$inPath  = "C:\Temp\teamname.csv"       #change the name of the .csv as needed. 
$outPath = "C:\Temp\teamnameOut.csv"    #be sure to change the name of the output file. 

$rows = Import-Csv $inPath

$rows2 = foreach ($r in $rows) {
  $dn = ([string]$r.DisplayName).Trim()

  if ([string]::IsNullOrWhiteSpace($dn)) { $r; continue }

  # Split on whitespace, ignore empties
  $parts = $dn -split '\s+' | Where-Object { $_ }

  # Remove the first name = drop the first token, keep all remaining tokens (supports 2+ last names)
  $lastParts = if ($parts.Count -ge 2) { $parts[1..($parts.Count-1)] } else { @($parts[0]) }

  # Join remaining tokens (removes spaces), then strip punctuation/non-alphanumerics
  # Keeps A-Z, a-z, 0-9 only
  $lastJoined = ($lastParts -join '')
  $lastClean  = $lastJoined -replace '[^A-Za-z0-9]', ''

  if ([string]::IsNullOrWhiteSpace($lastClean)) {
    # If everything got stripped, leave original
    $r
    continue
  }

  $r.DisplayName = "Team{0}Dynamic" -f $lastClean
  $r
}

$rows2 | Export-Csv -NoTypeInformation -Path $outPath
$outPath