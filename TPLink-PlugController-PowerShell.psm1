Function ConvertTo-TPLinkDataFormat {

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

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage = 'Body to Decode')]
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