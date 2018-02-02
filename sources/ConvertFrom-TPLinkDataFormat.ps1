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