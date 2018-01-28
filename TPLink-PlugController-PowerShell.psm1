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

    [cmdletbinding()]
    param (

        [Parameter(Mandatory=$True, Position=0, ParameterSetName='ClearTextCommand')]
        [string]$Command,

        [Parameter(Mandatory=$True, Position=0, ParameterSetName='JSONFormattedCommand')]
        [string]$JSON
    
    )

}