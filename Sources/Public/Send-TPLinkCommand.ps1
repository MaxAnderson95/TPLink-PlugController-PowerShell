Function Send-TPLinkCommand {

    <#

        .SYNOPSIS
        Sends a command to a TPLink HS100 or HS110 smart plug

        .DESCRIPTION
        This function can send a supported friendly command or a RAW JSON command to a TPLink
        smart plug and receive a response.

        .PARAMETER Command
        A string containing the command. Used instead of -JSON.

        .PARAMETER JSON
        A string contianing the raw JSON command. Used instead of -Command.

        .PARAMETER IPAddress
        The IP address of the TPLink smart plug

        .PARAMETER Output
        A string contining the desired output type. A validate set allows 'JSON','Object', or 'Friendly'

        .PARAMETER Port
        The TCP port number to send the messeges on. The default is TCP port 9999 and shouldn't ever need to be changed.

        .EXAMPLE
        PS > Send-TPLinkCommand -Command TurnOn -IPAddress 192.168.1.2

        .EXAMPLE
        PS > Send-TPLinkCommand -JSON '{"system":{"set_relay_state":{"state":1}}}' -IPAddress 192.168.1.2

        .NOTES
        A full list of commands can be found at https://github.com/MaxAnderson95/TPLink-PlugController-PowerShell/blob/master/Sources/TPLink-Smarthome-commands.txt
        
    #>

    [CmdletBinding()]
    param (

        [Parameter(ParameterSetName='FriendlyCommand',Mandatory=$True,Position=0)]
        [ValidateSet(
            'TurnOn',
            'TurnOff',    
            'SystemInfo',
            'Reboot',
            'Reset'
        )]
        [string]$Command,

        [Parameter(ParameterSetName='JSONFormattedCommand',Mandatory=$True,Position=0)]
        [string]$JSON,

        [Parameter(ParameterSetName='FriendlyCommand',Mandatory=$True,Position=1)]
        [Parameter(ParameterSetName='JSONFormattedCommand',Mandatory=$True,Position=1)]
        [ipaddress]$IPAddress,

        [Parameter(ParameterSetName='FriendlyCommand',Position=2)]
        [Parameter(ParameterSetName='JSONFormattedCommand',Position=2)]
        [ValidateSet(
            'JSON',
            'Object',
            'None'
        )]
        [string]$Output = 'Object',

        [Parameter(ParameterSetName='FriendlyCommand',Position=3)]
        [Parameter(ParameterSetName='JSONFormattedCommand',Position=3)]
        [int]$Port = 9999,
		
        [switch]$NoWait
    
    )

    $JSONCommands = @{
        SystemInfo = '{"system":{"get_sysinfo":null}}'
        Reboot = '{"system":{"reboot":{"delay":1}}}'
        Reset = '{"system":{"reset":{"delay":1}}}'
        TurnOn = '{"system":{"set_relay_state":{"state":1}}}'
        TurnOff = '{"system":{"set_relay_state":{"state":0}}}'
    }

    #Create an instance of the .Net TCP Client class
    $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient

    #Use the TCP client class to connect to the TP-Link plug
    $TCPClient.connect($IPAddress,$Port)

    #Return the network stream from the TCP client
    $Stream = $TCPClient.GetStream()

    Switch ($PSCmdlet.ParameterSetName) {

        'FriendlyCommand' {

            #Convert the friendly command to the corresponding JSON command
            $JSON = $JSONCommands.$Command

            #Convert the JSON command to TPLink byte format
            $EncodedCommand = ConvertTo-TPLinkDataFormat -Body $JSON

        }

        'JSONFormattedCommand' {

            #Convert the JSON command to TPLink byte format
            $EncodedCommand = ConvertTo-TPLinkDataFormat -Body $JSON

        }

    }

    #Write the command to the TCP Client stream twice. Unsure why twice.
    $Stream.write($EncodedCommand,0,$EncodedCommand.Length)
    $Stream.write($EncodedCommand,0,$EncodedCommand.Length)

    #If NoWait, exit immediately and don't wait for response
    if ($NoWait) { return $true }
	
    #Wait for data to become available
    While ($TCPClient.Available -eq 0) {
            
        Write-Debug "TCP Client Availablity buffer was not initially filled!"
        Write-Verbose "TCP Client Availablity buffer was not initially filled!"
        Start-Sleep -Seconds 1
    
    }

    #Start an additional half second sleep to allow all of the data to come in
    Start-Sleep -Milliseconds 500

    #Create a Byte object the size of the reponse that will hold the response from the plug.
    $BindResponseBuffer = New-Object Byte[] -ArgumentList $TCPClient.Available    

    #Use the read method and specify the buffer, the offset, and the size
    $Read = $stream.Read($bindResponseBuffer, 0, $bindResponseBuffer.Length)

    #If the read comes back empty, break out of the While loop
    If ($Read -eq 0){
        
        break
    
    } Else {

        [Array]$BytesReceived += $bindResponseBuffer[0..($Read -1)]
        [Array]::Clear($bindResponseBuffer, 0, $Read)
        
    }

    #Debug
    Write-Debug "TCPClient connection status is: $($TCPClient.Connected)"

    If ($BytesReceived -eq $Null) {

        Write-Error "No response received from the plug"

    } Else {

        Switch ($Output) {

            'JSON' {

                $Response = ConvertTo-JSON (ConvertFrom-JSON -InputObject (ConvertFrom-TPLinkDataFormat -Body $BytesReceived))
                Write-Debug "The Type of Data is $($Response.GetType())"

            }
            
            'Object' {

                $Response = ConvertFrom-JSON -InputObject (ConvertFrom-TPLinkDataFormat -Body $BytesReceived)
                
            }

            'None' {

                Break

            }

        }
        

        Write-Output $Response

    }

    #Cleanup the Network Stack
    $Bytesreceived = $null
    $Response = $null
    $bindResponseBuffer = $null
    $Stream.Flush()
    $Stream.Dispose()
    $Stream.Close()
    $Tcpclient.Dispose()
    $Tcpclient.Close()

}
