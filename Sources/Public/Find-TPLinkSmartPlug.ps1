Function Find-TPLinkSmartPlug {

    <#

    #>

    [CmdletBinding()]
    Param (
        
    )

    #Check for the IPv4 Resource files
    Write-Verbose "Checking for the IPv4 Network Scanner resource files"
    $ResourceCheck = Test-Path "$PSScriptRoot\..\Resources\IPv4-Network-Scanner\"

    If (!$ResourceCheck) {

        #If they're not found, error and end the script
        Write-Error "IPv4-Network-Scanner resource not found. Please re-clone/download the TPLink PowerShell repo."
        Break
        
    }

    Write-Verbose "IPv4 Network Scanner resource files found"

}