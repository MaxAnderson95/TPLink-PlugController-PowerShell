Function ConvertTo-TPLinkDataFormat {

    <#

        .SYNOPSIS
        Converts a JSON formatted command to the "encrypted" byte form that the TPLink plug will accept

        .PARAMETER Body
        A string that consits of the JSON formatted command to the plug

        .EXAMPLE
        ConvertTo-TPLinkDataFormat -Body '{"system":{"set_relay_state":{"state":1}}}'

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, HelpMessage = 'Body to Encode')]
        [String]$Body
    )
      
    $enc = [system.Text.Encoding]::UTF8
    # Now lets use the encoding method to return the un-encrypted byte array
    $bytes = $enc.GetBytes($Body) 
    # Tplink uses a dummy first 4 bytes so we just pass four 0's back
    for($i = 0; $i -lt 4;$i++){
        write-output 0
    }
    #The first encryption key for the bxor method is 171
    [byte]$key = 171
    # Loop through the byte array then use the next character byte value as the key
    for($i=0; $i -lt $bytes.count ; $i++)
    {
        $a = $key -bxor $bytes[$i]
        $key = $a
        # Return the 'encrypted' byte
        write-output $a
    }
    
}

Function ConvertFrom-TPLinkDataFormat {

    <#

        .SYNOPSIS
        Converts an "encrypted" byte reply from the TPLink plug into readable JSON format

        .PARAMETER Body
        A byte array response to be converted back into readable JSON

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Body,
        
        [switch]$IncludeBytes = $false
    )
        
    [byte]$key = 171
    for($i=4; $i -lt $body.count ; $i++)
    {
        $a = $key -bxor $Body[$i]
        $key = $body[$i]
        [string]$origret += "$([string]$a),"
        $return += $([char]$a)
        
    }
    
    Write-Output $return
    if($includeBytes){Write-Output $origret}
    
}

Function Send-TPLinkCommand {

    <#

    #>

    [CmdletBinding()]
    param (

        [Parameter(ParameterSetName='ClearTextCommand',Mandatory=$True,Position=0)]
        [string]$Command,

        [Parameter(ParameterSetName='JSONFormattedCommand',Mandatory=$True,Position=0)]
        [string]$JSON,

        [Parameter(ParameterSetName='ClearTextCommand',Mandatory=$True,Position=1)]
        [Parameter(ParameterSetName='JSONFormattedCommand',Mandatory=$True,Position=1)]
        [ipaddress]$IPAddress,
        
        [Parameter(ParameterSetName='ClearTextCommand',Position=2)]
        [Parameter(ParameterSetName='JSONFormattedCommand',Position=2)]
        [int]$Port = 9999
    
    )

    #Create an instance of the .Net TCP Client class
    $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient

    #Use the TCP client class to connect to the TP-Link plug
    $TCPClient.connect($IPAddress,$Port)

    #Return the network stream from the TCP client
    $Stream = $TCPClient.GetStream()

    #Convert the JSON command to TPLink byte format
    $EncodedCommand = ConvertTo-TPLinkDataFormat -Body $JSON

    #Write the command to the TCP Client stream as many times as needed. This is usually twice for some reason.
    Do {
        
        $Stream.write($EncodedCommand,0,$EncodedCommand.Length)

        #Debug
        $Debug_StreamWriteCount = $Debug_StreamWriteCount + 1
        Write-Debug "The Stream has been written to $Debug_StreamWriteCount time(s). DataAvailable is currently $($Stream.DataAvailable)"
        #Debug

    } Until (
        
        $Stream.DataAvailable -eq $True
    
    )

    #Create a Byte object the size of the reponse that will hold the response from the plug.
    $BindResponseBuffer = New-Object Byte[] -ArgumentList $TCPClient.Available

    # Loop through the buffer till we get the full JSON response    
    While ($TCPClient.Connected -eq $True) {

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

    }

    If ($BytesReceived -eq $Null) {

        Write-Output "No response received from the plug"

    } Else {

        $Response = ConvertFrom-Json -InputObject (ConvertFrom-TPLinkDataFormat -Body $BytesReceived)

        Write-Output $Response

    }

    #Cleanup the Network Stack
    $Stream.Flush()
    $Tcpclient.Dispose()
    $Tcpclient.Close()

}