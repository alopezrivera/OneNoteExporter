# SPDX-License-Identifier: GPL-3.0

Function Truncate-PathFileName {
    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter(ParameterSetName='default',Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    ,
        [Parameter(ParameterSetName='pipeline',ValueFromPipeline)]
        [string]
        $InputObject
    ,
        [Parameter()]
        [ValidateRange(0,255)]
        [int]
        $Length
    )

    process {
        if ($InputObject) {
            $Path = $InputObject
        }
        if ($null -eq $Path) {
            throw "No input parameters specified."
        }
        $maxLength = 255
        if ($Length) {
            $maxLength = $Length
        }

        # On Windows, even with support for long absolute file paths, there's still a limit for file or folder names (i.e. File or folder name limit: Max 255 characters long)
        $name = Split-Path $Path -Leaf
        if ($name.Length -gt $maxLength) {
            $parent = Split-Path $Path -Parent
            $truncatedName = $name.Substring(0, $maxLength)
            [io.path]::combine( $parent, $truncatedName )
        }else {
            $Path
        }
    }
}

Function Remove-InvalidFileNameChars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string]$Name
    ,
        [switch]$KeepPathSpaces
    )

    # Remove boundary whitespaces. So we don't get trailing dashes
    $Name = $Name.Trim()

    $newName = $Name.Split([IO.Path]::GetInvalidFileNameChars()) -join '-'
    $newName = $newName -replace "\[", "("
    $newName = $newName -replace "\]", ")"
    $newName =  if ($KeepPathSpaces) {
                    $newName -replace "\s", " "
                } else {
                    $newName -replace "\s", "-"
                }
    return $newName
}

Function Remove-InvalidFileNameCharsInsertedFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string]$Name
    ,
        [string]$Replacement = ""
    ,
        [string]$SpecialChars = "#$%^*[]'<>!@{};"
    ,
        [switch]$KeepPathSpaces
    )

    # Remove boundary whitespaces. So we don't get trailing dashes
    $Name = $Name.Trim()

    $rePattern = ($SpecialChars.ToCharArray() | ForEach-Object { [regex]::Escape($_) }) -join "|"

    $newName = $Name.Split([IO.Path]::GetInvalidFileNameChars()) -join '-'
    $newName = $newName -replace $rePattern, ""
    $newName =  if ($KeepPathSpaces) {
                    $newName -replace "\s", " "
                } else {
                    $newName -replace "\s", "-"
                }
    return $newName
}