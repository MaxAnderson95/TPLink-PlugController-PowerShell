#
# Module manifest for module 'TPLink-PlugController-PowerShell'
#
# Generated by: Max Anderson
#
# Generated on: 1/30/2018
#

@{

# Version number of this module.
ModuleVersion = '1.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '7e356b34-7608-456b-8122-db9cace0c020'

# Author of this module
Author = 'Max Anderson'

# Company or vendor of this module
CompanyName = 'MaxAnderson.technology'

# Copyright statement for this module
Copyright = '(c) 2018 Max Anderson. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Allows the control of a TPLink HS100 or HS110 smart wall plug using PowerShell.'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(

    '.\Sources\Send-TPLinkMessage.ps1',
    '.\Sources\ConvertFrom-TPLinkDataFormat.ps1',
    '.\Sources\ConvertTo-TPLinkDataFormat.ps1'

)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Send-TPLinkCommand')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

}