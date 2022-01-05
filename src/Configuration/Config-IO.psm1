# SPDX-License-Identifier: GPL-3.0

Function New-ConfigurationFile {
    [CmdletBinding()]
    param ()

    # Generate a configuration file config.example.ps1
    @'
#
# Note: This config file is for those who are lazy to type in configuration everytime you run ./ConvertOneNote2MarkDown-v2.ps1
#
# Steps:
#   1) Rename this file to config.ps1. Ensure it is in the same folder as the ConvertOneNote2MarkDown-v2.ps1 script
#   2) Configure the options below to your liking
#   3) Run the main script: ./ConvertOneNote2MarkDown-v2.ps1. Sit back while the script starts converting immediately.
'@ | Out-File "$PSScriptRoot/config.example.ps1" -Encoding utf8

    $defaultConfig = Get-DefaultConfiguration
    foreach ($key in $defaultConfig.Keys) {
        # Add a '#' in front of each line of the option description
        $defaultConfig[$key]['description'].Trim() -replace "^|`n", "`n# " | Out-File "$PSScriptRoot/config.example.ps1" -Encoding utf8 -Append

        # Write the variable
        if ( $defaultConfig[$key]['default'] -is [string]) {
            "`$$key = '$( $defaultConfig[$key]['default'] )'" | Out-File "$PSScriptRoot/config.example.ps1" -Encoding utf8 -Append
        }else {
            "`$$key = $( $defaultConfig[$key]['default'] )" | Out-File "$PSScriptRoot/config.example.ps1" -Encoding utf8 -Append
        }
    }
}

Function Print-Configuration {
    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter(ParameterSetName='default',Position=0)]
        [object]
        $Config
    ,
        [Parameter(ParameterSetName='pipeline',ValueFromPipeline)]
        [object]
        $InputObject
    )
    process {
        if ($InputObject) {
            $Config = $InputObject
        }
        if ($null -eq $Config) {
            throw "No input parameters specified."
        }

        foreach ($key in $Config.Keys) {
            "$( $key ): $( $Config[$key]['value'] )" | Write-Host -ForegroundColor DarkGray
        }
    }
}