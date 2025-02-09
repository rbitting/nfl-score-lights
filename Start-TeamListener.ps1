<#
.DESCRIPTION
  Listens to score changes for the specified team and flashes Hue lights when a change is detected.
.PARAMETER TeamAbbreviation
  The abbreviation for the NFL team. Ex. 'PHI'
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $True, HelpMessage = "Enter the NFL team abbreviation. Ex. 'PHI'")]
  [String]$TeamAbbreviation
)

Import-Module ./HueModule.psm1
Import-Module ./PushbulletModule.psm1

[bool]$isVerbose = $PSBoundParameters['Verbose'] -eq $True

Write-Verbose "Url: $url"
$previousScore = 0;
while ($True) {
  try {
    [String]$today = Get-Date -Format "yyyyMMdd"
    [String]$url = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?dates=$today"
    $response = Invoke-RestMethod -Uri $url -Method Get
    $events = $response.events
    $eventFound = $False
    $teamFound = $False

    # Find relevant event in all events today
    foreach ($event in $events) {
      if ($event.shortName.Contains($TeamAbbreviation)) {
        Write-Verbose "Event found: $($event.id) $($event.name) ($($event.shortName))"
        $competitors = $event.competitions[0].competitors

        # Find relevant team in competitors for event
        foreach ($competitor in $competitors) {
          if ($competitor.team.abbreviation -eq $TeamAbbreviation) {
            Write-Verbose "Competitor found: $($competitor.id) $($competitor.team.displayName) ($($competitor.team.abbreviation))"
            $currentScore = [Int]$competitor.score

            # Check if the score has changed
            if ($currentScore -ne $previousScore) {
              Write-Output "$(Get-Date) -- Score changed from $previousScore to $currentScore"
              $previousScore = $competitor.score;

              # Invoke Hue action
              Invoke-FlashLights -Verbose:$isVerbose
            }
            else {
              Write-Output "$(Get-Date) -- Current Score: $currentScore"
            }
            $teamFound = $True
            break
          }
        } 

        # Throw error if team wasn't found
        # Edge case that isn't expected to be hit since there's already a check for the team in the event name
        if (!$teamFound) {
          throw "Team '$TeamAbbreviation' could not be found in competitors for event id $($event.id)"
        }

        $eventFound = $True
        break
      }
    }

    # Throw error if the event wasn't found
    if (!$eventFound) {
      throw "Event for '$TeamAbbreviation' could not be found on $today"
    }

    # Wait 10 seconds
    Start-Sleep -Seconds 10
  }
  catch {
    $errorMessage = $_
    Send-PushbulletNote -Title "Score Lights Error" -Body $errorMessage -Verbose:$isVerbose
    Write-Host $errorMessage -ForegroundColor Red # Log error
    exit 1
  }
}

exit 0
