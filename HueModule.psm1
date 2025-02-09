# Set the environment variables from the .env file
Get-Content .env | ForEach-Object {
  $name, $value = $_.split('=')
  Set-Content env:\$name $value
}

<#
.DESCRIPTION
  Flashes the lights between the specified scene and the default scene
#>
function Invoke-FlashLights {
  [bool]$isVerbose = $PSBoundParameters['Verbose'] -eq $True
  [String]$turnOnSceneAction = '{ "recall": { "action": "active", "dimming": { "brightness": 100 } } }'

  # Note that the brightness of 0 changes it to lowest possible brightness (not off)
  # TODO: Figure out how to turn the scene all the way off
  [String]$turnOffSceneAction = '{ "recall": { "action": "active", "dimming": { "brightness": 0 } } }'

  1..4 | ForEach-Object { 
    Send-HueSceneAction -SceneId $Env:HUE_SCENE_ID_COLOR2 -Data $turnOnSceneAction -Verbose:$isVerbose
      
    Start-Sleep -Seconds 0.5
      
    Send-HueSceneAction -SceneId $Env:HUE_SCENE_ID_COLOR1 -Data $turnOnSceneAction -Verbose:$isVerbose

    Start-Sleep -Seconds 0.4
  }

  Send-HueSceneAction -SceneId $Env:HUE_SCENE_ID_COLOR1 -Data $turnOffSceneAction -Verbose:$isVerbose
}

<#
.DESCRIPTION
  Sends an PUT request for a specific scene to the Hue bridge
#>
function Send-HueSceneAction {
  [CmdletBinding()]
  param (
    [String]$SceneId,
    $Data
  )
  [bool]$isVerbose = $PSBoundParameters['Verbose'] -eq $True
  [String]$url = "https://$Env:HUE_IP/clip/v2/resource/scene/$SceneId"
  [String]$command = "& curl -k --location --request PUT $url --header `"Content-Type: application/json`" --header `"hue-application-key: $Env:HUE_USERNAME`" --data '$Data'"
  
  Write-Verbose "Url: $url"
  if ($isVerbose) {
    Write-Verbose "Running command: $command"
    Invoke-Expression $command
  }
  else {
    Invoke-Expression "$command --silent --output nul --show-error --fail"
  }
}