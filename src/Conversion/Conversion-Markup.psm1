# SPDX-License-Identifier: GPL-3.0

Function Get-Markup
{
    [CmdletBinding()]
    param (
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    $keys = @("markdown", "org", "gfm", "commonmark")

    # Get markup format from Pandoc call
    $markup = "none"
    foreach ($key in $keys) {
        if ($pageCfg['conversion'] -Match $key) {
            $markup = $key
        }
    }

    $markup

}

Function Get-MarkupExtension
{
    [CmdletBinding()]
    param (
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    # Markup formats hashtable
    $markupTable = @{
        markdown   = "md";
        gfm        = "md";
        commonmark = "md";
        org        = "org";
    }

    # Get markup format from Pandoc call
    $markup = Get-Markup $pageCfg

    $extension = $markupTable[$markup]

    $extension

}

Function Get-MarkupPack
{
    [CmdletBinding()]
    param (
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    # Get markup format from Pandoc call
    $markup = Get-Markup $pageCfg

    Write-Host "------------------------"
    Write-Host "------------------------"

}