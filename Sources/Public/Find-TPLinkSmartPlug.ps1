Function Find-TPLinkSmartPlug {

    <#

    #>

    [CmdletBinding()]
    Param (
        
    )

    $ResourceCheck = Test-Path "$PSScriptRoot\..\Resources\IPv4-Network-Scanner\"

    If (!$ResourceCheck) {

        Write-Error "IPv4-Network-Scanner resource not found. Please re-clone/download the TPLink PowerShell repo."
        Break
        
    }

    Write-Verbose "IPv4 Network Scanner resource found"

}