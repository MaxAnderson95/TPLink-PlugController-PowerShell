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

    Try {
        
        #Get the IP address and CIDR of the current running machine
        Write-Verbose "Attempting to get IP and subnet information from the machine"
        $NetInfo = (Get-NetIPAddress -AddressFamily IPv4)[0] | Select-Object IPAddress,PrefixLength

    }
    
    Catch {

        Write-Error "Unable to find IP address or adapter information."
        Break

    }

    #Start a network scan using 3rd party script
    $ScanResults = ..\Resources\IPv4-Network-Scanner\IPv4NetworkScan.ps1 -IPv4Address $NetInfo.IPAddress -CIDR $NetInfo.PrefixLength -DisableDNSResolving -EnableMACResolving

    #Filter the results for TPLink Smart Plugs
    $FoundPlugs = $ScanResults | Where-Object { $_.Vendor -like "*TP-Link*" }

}