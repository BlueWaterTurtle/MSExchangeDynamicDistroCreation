#I've created this script to create multiple DDG's based on the .csv export from using the "ddgprintteam.ps1" script. 


# Path to the input CSV file.
# The CSV MUST have headers: TeamName, ManagerEmail
$csvPath = "C:\Temp\teams.csv" 

# Path where we will write a results/log CSV (Created/Skipped/Failed, etc.)
$logPath = ("C:\Temp\ddg-create-log-{0:yyyyMMdd-HHmmss}.csv" -f (Get-Date))

function New-SafeAlias {
  param([Parameter(Mandatory=$true)][string]$Name)

  # Convert the group name to a "safe" alias (mailNickname):
  # - lowercase
  # - replace any non a-z or 0-9 characters with "-"
  # - collapse repeated "-" into single "-"
  # - trim "-" from the start/end
  $alias = $Name.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
  $alias = ($alias -replace '-{2,}', '-').Trim('-')

  # If we stripped everything (e.g., the name was only symbols), fall back to "ddg"
  if ([string]::IsNullOrWhiteSpace($alias)) { $alias = "ddg" }

  # Keep alias reasonably short (Exchange supports up to ~64; we stay under 50)
  if ($alias.Length -gt 50) { $alias = $alias.Substring(0,50).Trim('-') }

  return $alias
}

# Read all rows from the CSV. Each row becomes an object with properties:
# $row.TeamName and $row.ManagerEmail
$rows = Import-Csv $csvPath

# Process each CSV row and build a results object for logging.
$results = foreach ($row in $rows) {

  # Pull the two fields we care about from the CSV row
  $teamName  = ([string]$row.TeamName).Trim()
  $managerId = ([string]$row.ManagerEmail).Trim()

  # Build a log record for this row (we will fill in Status/Details later)
  $out = [ordered]@{
    TeamName     = $teamName
    ManagerEmail = $managerId
    Alias        = ""
    Status       = ""
    Details      = ""
  }

  # Validate required CSV data exists for this row
  if ([string]::IsNullOrWhiteSpace($teamName) -or [string]::IsNullOrWhiteSpace($managerId)) {
    $out.Status  = "Skipped"
    $out.Details = "Missing TeamName or ManagerEmail"
    [pscustomobject]$out
    continue
  }

  # Skip creating a new DDG if a DDG with this identity already exists
  # NOTE: this only checks DynamicDistributionGroup objects (not all group types).
  if (Get-DynamicDistributionGroup -Identity $teamName -ErrorAction SilentlyContinue) {
    $out.Status  = "Skipped"
    $out.Details = "Already exists"
    [pscustomobject]$out
    continue
  }

  # Resolve the manager from the identifier in ManagerEmail.
  # We then use the manager's DistinguishedName (DN) in the DDG filter.
  try {
    $managerDn = (Get-User -Identity $managerId -ErrorAction Stop).DistinguishedName
  } catch {
    # If the manager can't be found, skip this row (cannot build the membership rule)
    $out.Status  = "Skipped"
    $out.Details = "Manager not found"
    [pscustomobject]$out
    continue
  }

  # Escape single quotes to safely embed the DN inside the filter string.
  $escapedManagerDn = $managerDn -replace "'", "''"

  # Dynamic membership rule:
  # - Include mailbox users whose Manager attribute equals this manager's DN
  # - Limit to UserMailbox recipients (direct reports with mailboxes)
  $filter = "(Manager -eq '$escapedManagerDn') -and (RecipientTypeDetails -eq 'UserMailbox')"

  # Create a predictable/safe alias from the team name (mailNickname)
  $alias = New-SafeAlias -Name $teamName
  $out.Alias = $alias

  # Try to create the DDG; if it fails, capture the error message in the log
  try {
    New-DynamicDistributionGroup `
      -Name $teamName `
      -Alias $alias `
      -RecipientFilter $filter `
      -ErrorAction Stop | Out-Null

    $out.Status  = "Created"
    $out.Details = "OK"
  } catch {
    $out.Status  = "Failed"
    $out.Details = $_.Exception.Message
  }

  # Output a single log object for this CSV row
  [pscustomobject]$out
}

# Write the results log to CSV so you can review Created/Skipped/Failed afterward
$results | Export-Csv -NoTypeInformation -Path $logPath

# Print a readable table summary in the console
$results | Format-Table -AutoSize

# Print where the log was saved
"Log written to: $logPath"