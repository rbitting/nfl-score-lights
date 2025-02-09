# Set the environment variables from the .env file
Get-Content .env | ForEach-Object {
  $name, $value = $_.split('=')
  Set-Content env:\$name $value
}

<#
.DESCRIPTION
  Sends a Pushbullet note with the specified title and body to all devices
#>
function Send-PushbulletNote {
  [CmdletBinding()]
  param (
    [String]$Title,
    [String]$Body
  )
  [String]$pushbulletAccessToken = $Env:PUSHBULLET_ACCESS_TOKEN
  if ([string]::IsNullOrEmpty($pushbulletAccessToken)) {
    Write-Output "No environment variable set for PUSHBULLET_ACCESS_TOKEN"
    return
  }

  try {
    [bool]$isVerbose = $PSBoundParameters['Verbose'] -eq $True

    # An error will be thrown from the curl command if single quotes aren't escaped properly
    [String]$escapedBody = $Body -replace "'", "''" 
    [String]$escapedTitle = $Title -replace "'", "''" 

    [String]$command = "curl --header 'Access-Token: $pushbulletAccessToken' --header 'Content-Type: application/json' --data-binary '{""body"":""$escapedBody"",""title"":""$escapedTitle"", ""type"":""note""}' --request POST https://api.pushbullet.com/v2/pushes"

    Write-Verbose "Sending Pushbullet with title '$escapedTitle' and body '$escapedBody'"
    if ($isVerbose) {
      $response = Invoke-Expression $command | Out-String
      Write-Verbose $response
    }
    else {
      $response = Invoke-Expression "$command --silent" | Out-String
    }
    
    # Throw an error if an error object is returned in the response body
    $responseObject = ConvertFrom-JSON -InputObject $response
    if ($responseObject | Get-Member -Name "error") {
      throw "$($responseObject.error.code): $($responseObject.error.message)"
    }
  }
  catch {
    # Log error but don't rethrow
    Write-Host "Error: could not send Pushbullet note" -ForegroundColor Yellow
    Write-Host $_ -ForegroundColor Yellow
  }
} 