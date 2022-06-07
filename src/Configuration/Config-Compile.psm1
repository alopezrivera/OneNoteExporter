# SPDX-License-Identifier: GPL-3.0

Function Compile-Configuration {
    
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $configPath
    )

    # Get a default configuration
    $config = Get-DefaultConfiguration

    # Override configuration
    $configFile = [io.path]::combine( $configPath, 'config.ps1' )
    if (Test-Path $configFile) {
        try {
            & {
                $scriptblock = [scriptblock]::Create( (Get-Content -LiteralPath $configFile -Raw) )
                . $scriptblock *>$null # Cleanup the pipeline
                foreach ($key in @($config.Keys)) {
                    # E.g. 'string', 'int'
                    $typeName = [Microsoft.PowerShell.ToStringCodeMethods]::Type($config[$key]['default'].GetType())
                    $config[$key]['value'] = Invoke-Expression -Command "(Get-Variable -Name `$key -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value) -as [$typeName]"
                    if ($config[$key]['value'] -is [string]) {
                        # Trim string
                        $config[$key]['value'] = $config[$key]['value'].Trim()

                        # Remove trailing slash(es) for paths
                        if ($key -match 'path' -and $config[$key]['value'] -match '[/\\]') {
                            $config[$key]['value'] = $config[$key]['value'].TrimEnd('/').TrimEnd('\')
                        }
                    }
                    # Fallback on default value if the input is empty string
                    if ($config[$key]['value'] -is [string] -and $config[$key]['value'] -eq '') {
                        $config[$key]['value'] = $config[$key]['default']
                    }
                    # Fallback on default value if the input is empty integer (0)
                    if ($config[$key]['value'] -is [int] -and $config[$key]['value'] -eq 0) {
                        $config[$key]['value'] = $config[$key]['default']
                    }
                }
            }
        }catch {
            Write-Warning "There is an error in the configuration file $configFile $( $_.ScriptStackTrace ). `nThe exception was: $( $_.Exception.Message )"
            throw
        }
    }else {
        throw "
        `n================================================================================
        `nNo configuration file found. Please rename 'config example.ps1' to 'config.ps1'. 
        `nConsider reading through the available configuration options as well.
        `nFor more information, visit: https://github.com/alopezrivera/owo#usage
        `n================================================================================
        `n"
    }

    $config

}

Function Validate-Configuration {
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

        # Validate a given configuration against a prototype configuration
        $defaultConfig = Get-DefaultConfiguration
        foreach ($key in $defaultConfig.Keys) {
            if (! $Config.Contains($key) -or ($null -eq $Config[$key]) -or ($null -eq $Config[$key]['value'])) {
                throw "Missing or invalid configuration option '$key'. Expected a value of type $( $defaultConfig[$key]['default'].GetType().FullName )"
            }
            if ($defaultConfig[$key]['default'].GetType().FullName -ne $Config[$key]['value'].GetType().FullName) {
                throw "Invalid configuration option '$key'. Expected a value of type $( $defaultConfig[$key]['default'].GetType().FullName ), but value was of type $( $config[$key]['value'].GetType().FullName )"
            }
            if ($defaultConfig[$key].Contains('validateOptions')) {
                if ($defaultConfig[$key]['validateOptions'] -contains 'directoryexists') {
                    if ( ! $config[$key]['value'] -or ! (Test-Path $config[$key]['value'] -PathType Container -ErrorAction SilentlyContinue) ) {
                        throw "Invalid configuration option '$key'. The directory '$( $config[$key]['value'] )' does not exist, or is a file"
                    }
                }
            }
            if ($defaultConfig[$key].Contains('validateRange')) {
                if ($Config[$key]['value'] -lt $defaultConfig[$key]['validateRange'][0] -or $Config[$key]['value'] -gt $defaultConfig[$key]['validateRange'][1]) {
                    throw "Invalid configuration option '$key'. The value must be between $( $defaultConfig[$key]['validateRange'][0] ) and $( $defaultConfig[$key]['validateRange'][1] )"
                }
            }
        }

        # Warn of unknown configuration options
        foreach ($key in $config.Keys) {
            if (! $defaultConfig.Contains($key)) {
                "Unknown configuration option '$key'" | Write-Warning
            }
        }

        $Config
    }
}