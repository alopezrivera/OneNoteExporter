# SPDX-License-Identifier: GPL-3.0

Function DefaultMarkupPacks {
    @{
        org               = 'OrgPack1';
        md                = 'MarkdownPack1';
    }
}

Function SupportedMarkupFormats {

    # As specified in the Pandoc manual (https://pandoc.org/MANUAL.html)

    @{

        # Emacs Org Mode
        org               = 'org';

        # Markdown
        markdown_strict   = 'md';

        # CommonMark
        commonmark        = 'md';
        commonmark_x      = 'md';

        # GitHub-Flavored Markdown
        gfm               = 'md';
        markdown_github   = 'md';

        # Pandoc Markdown
        markdown          = 'md';

        # MultiMarkdown
        markdown_mmd      = 'md';
        
        # PHP Markdown Extra
        markdown_phpextra = 'md';

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

    $pandocCall = $pageCfg['conversion']
    
    $markup = $pandocCall.Split('-')[0]

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

    $markupTable = SupportedMarkupFormats

    $markup = Get-Markup $pageCfg

    $extension = $markupTable[$markup]

    $extension

}

Function Get-MarkupPack
{
    [CmdletBinding()]
    param (
        # one configuration object
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

        $defaultsPacks  = DefaultMarkupPacks

        $extension = Get-MarkupExtension $pageCfg

        $markupPack = $defaultsPacks[$extension]

    }
    else {
        $markupPack = $config['markupPack']['value']
    }

    $markupPack

}