# TPLink Plug Controller Module for PowerShell
This is a PowerShell module that can be used for controlling a TPLink HS100 or HS110 smart plug. The plug receives requests and this module sends requests on tcp port 9999, so theoretically this can traverse networks or the internet with proper port forwarding/NAT rules. However this can allow someone to control the device plugged into the TPLink plug, so do this with caution.

## Usage Instructions
1. Begin by downloading or cloning the repository to a directory of your choice. Preferably a directory in your `$env:PSModulePath` so that the module will auto-load itself when running any of the exported functions.
![Cloning the repo gif](https://i.imgur.com/4jYVufF.gif)

2. Determine the IP address of your plug using `Find-TPLinkSmartPlug`.
![Finding Smart Plugs](https://i.imgur.com/Ky4i5bU.gif)

3. Send a command to your unit. For example we can turn on the unit.
![Sending the command Friendly](https://i.imgur.com/AsSGV5L.gif)
Or Send the command using raw JSON.
![Sending the command](https://i.imgur.com/QhuCZtW.gif)

*Optional*

4. `The Send-TPLinkCommand` outputs a PSCustomObject with the respose. This is generated from the raw JSON response from the plug. This response can be placed in a variable and analyzed.
![Analyzing the output](https://i.imgur.com/AiXksBt.gif)

### List of Available JSON Commands
Click [here](https://github.com/MaxAnderson95/TPLink-PlugController-PowerShell/blob/master/Sources/Resources/TPLink-Smarthome-commands.txt) to find a list of valid JSON commands the HS100 or HS110 will accept.

## Credit
Big thanks to [EgoManiac's TPLink-PoSH](https://github.com/EgoManiac/TPlink-PoSH) for the code base for this project. My goal with this was to: cleanup the code, convert this to module format, and give myself a project.
