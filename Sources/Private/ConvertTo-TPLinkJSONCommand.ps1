Function ConvertTo-TPLinkJSONCommand {

    <#

        .SYNOPSIS
        Takes a given "Friendly" input and outputs the corresponding JSON command that the TPLink plug will accept.

        .PARAMETER Input
        An approved "Friendly" command in string format

        .EXAMPLE
        PS > ConvertTo-TPLinkJSONCommand -Input "TurnOn"
        "{""system"":{""set_relay_state"":{""state"":1}}}"

        .NOTES
        This function is not designed to be exported or for public use, thus the function does not validate that the
        input for "InputObject" is a friendly command that is accepted. It also will output an empty respose if one 
        is not found. This function leaves these two things up to the functions calling them.

    #>

    Param (

        [Parameter(Mandatory=$True)]
        [String]$InputObject,

        [Parameter()]
        [String]$FilePath = "$PSScriptRoot\FriendlyCommandMapping.csv"


    )

    Try {
        
        #Import the CSV containing the mappings between friendly names and their JSON formatted versions
        $FriendlyNameMapping = Import-Csv -Path $FilePath
    
    }
    Catch {

        Write-Error "CSV mapping file not found. Either the default mapping file is not present or the one specified in -FilePath was not found."
        Break

    }

    $JSON = ($FriendlyNameMapping | Where-Object { $_.Command -eq $InputObject }).JSON

    Write-Output $JSON

}   