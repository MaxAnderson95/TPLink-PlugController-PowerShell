Function Find-TPLinkSmartPlug {

    <#

        .SYNOPSIS
        Searches the network for TPLink Smart Hubs

        .EXAMPLE
        PS > Find-TPLinkSmartPlug
        IPv4Address Status MAC               Vendor
        ----------- ------ ---               ------
        10.11.12.76 Up     70-4F-57-DB-3E-E0 TP-Link Technologies Co. Ltd

    #>

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
        $IPaddress =  (Get-NetIPAddress -AddressFamily IPv4) | Select-Object IPAddress,PrefixLength
        $NetInfo =  $IPaddress | Where-Object {($_.IPAddress -match "(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)")}

    }

    Catch {

        Write-Error "Unable to find IP address or adapter information."
        Break

    }

    #Start a network scan using 3rd party script
    $ScanResults = . $PSScriptRoot\..\Resources\IPv4-Network-Scanner\IPv4NetworkScan.ps1 -IPv4Address $NetInfo.IPAddress -CIDR $NetInfo.PrefixLength -DisableDNSResolving -EnableMACResolving

    #Filter the results for TPLink Smart Plugs
    $possible = $ScanResults | Where-Object { $_.Vendor -like "*TP-Link*" }

    foreach ($ip in $possible) {
        $connection = (New-Object Net.Sockets.TcpClient)
        $connection.Connect($ip.IPv4Address,9999)
        if ($connection.Connected) {
            $FoundPlugs += $ip
            }
    }


    If ($FoundPlugs -eq $Null) {

        Write-Error "No TPLink Smart Plugs found on your network"
        Break

    }
    
    Else {

        Write-Output $FoundPlugs

    }

}