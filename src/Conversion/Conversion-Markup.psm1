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

    $keys = @('markdown', 'org', 'gfm', 'commonmark')

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
    $markupTable = @{
        markdown   = 'md';
        gfm        = 'md';
        commonmark = 'md';
        org        = 'org';
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
    if ($config['markupPack']['value'] -eq 'none') {
        # Markup packs hastable
        $markupPacks = @{
            org = 'OrgPack1';
            md  = 'MarkdownPack1';
        }

        # Get markup format from Pandoc call
        $extension = Get-MarkupExtension $pageCfg

        $markupPack = $markupPacks[$extension]

    }
    # Otherwise, return Markup Pack specified in config.ps1
    else
    {
        $markupPack = $config['markupPack']['value']
    }

    $markupPack

}