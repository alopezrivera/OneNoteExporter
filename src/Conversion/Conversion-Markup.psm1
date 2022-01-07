# SPDX-License-Identifier: GPL-3.0

Function SupportedMarkupFormats {
    @{
        markdown   = 'md';
        gfm        = 'md';
        commonmark = 'md';
        org        = 'org';
    }
}

Function DefaultMarkupPacks {
    @{
        org = 'OrgPack1';
        md  = 'MarkdownPack1';
    }
}

Function Get-Markup
{
    [CmdletBinding()]
    param (
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    $markupTable = SupportedMarkupFormats

    $keys = $markupTable.Keys

    # Get markup format from Pandoc call
    $markup = 'none'
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
    $markupTable = SupportedMarkupFormats

    # Get markup format from Pandoc call
    $markup = Get-Markup $pageCfg

    $extension = $markupTable[$markup]

    $extension

}

Function Get-MarkupPack
{
    [CmdletBinding()]
    param (
        # OneUp configuration object
        [Parameter(Mandatory)]
        [object]
        $config
        ,
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    # If no specific Markup Pack has been specified in config.ps1
    if ($config['markupPack']['value'] -eq '') {
        # Markup packs hastable
        $markupPackHastable = DefaultMarkupPacks

        # Get markup format from Pandoc call
        $extension = Get-MarkupExtension $pageCfg

        $markupPack = $markupPackHastable[$extension]

    }
    # If no post-processing is desired, return 'none'
    elseif ($config['markupPack']['value'] -eq 'none') {
        $markupPack = 'none'
    }
    else
    {
        $markupPack = $config['markupPack']['value']
    }

    $markupPack

}

Function MarkupPackAvailable {

    [CmdletBinding()]
    param (
        # OneUp configuration object
        [Parameter(Mandatory)]
        [object]
        $config
        ,
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    # Get markup extensions with a default Markup Pack
    $markupPackHastable = DefaultMarkupPacks
    $supMarkupExtensions = $markupPackHastable.Keys

    # Get markup format from Pandoc call
    $extension = Get-MarkupExtension $pageCfg

    # Determine whether a Markup Pack is available for the conversion
    $markupPackAvailable = 0
    if ($config['markupPack']['value'] -eq '') {
        if ($supMarkupExtensions.Contains($extension)) {
            $markupPackAvailable = 1
        }
    }elseif ($config['markupPack']['value'] -ne 'none') {
        $markupPackAvailable = 1
    }

    $markupPackAvailable

}