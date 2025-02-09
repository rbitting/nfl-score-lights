# command-lights-status

Quick and dirty implementation of a command line application to flash between two Hue scenes when the specified NFL team scores.

## Requirements
1. [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4)

## Get Started

1. Generate a [Hue application key](https://developers.meethue.com/develop/hue-api-v2/getting-started/#so-lets-get-started) if you haven't already. Note that these instructions will generate a username and client key. Going forward, all we'll be using is the username.
2. Create two scenes in the Hue app for your teams colors and record the ids for them. For example, for the Eagles, the first scene can be all green and the second scene can be all white.
   - You can retrieve all scenes with the following command to find their ids:
     ```
     curl -k --location --request GET "[your hue bridge ip address]/clip/v2/resource/scene" \
       --header "Content-Type: application/json" \
       --header "hue-application-key: [your hue username]"
     ```
3. Create a `.env` file in this directory with the following content:
   ```
   HUE_IP=ip-address-of-your-hue-bridge
   HUE_USERNAME=your-hue-username-returned-from-step-1
   HUE_SCENE_ID_COLOR1=id-of-first-color
   HUE_SCENE_ID_COLOR1=id-of-second-color
   ```

## Run

```powershell
.\Start-TeamListener.ps1 -TeamAbbreviation [team abbreviation]
```

Example:

```powershell
.\Start-TeamListener.ps1 -TeamAbbreviation PHI
```

You can find the abbreviation for your team [from the ESPN API](https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams).
