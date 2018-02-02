Function ConvertTo-TPLinkJSONCommand {

    <#

        .SYNOPSIS
        Takes a given "Friendly" input and outputs the corresponding JSON command that the TPLink plug will accept.

        .PARAMETER Input
        An approved "Friendly" command in string format

        .EXAMPLE
        PS > ConvertTo-TPLinkJSONCommand -Input "TurnOn"
        "{""system"":{""set_relay_state"":{""state"":1}}}"

    #>

    Param (

        [Parameter(Mandatory=$True)]
        [String]$Input

    )

    

}