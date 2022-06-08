# SPDX-License-Identifier: GPL-3.0

# This is a copy of the OrgPack1 Markup Pack for Emacs Org Mode, with some indications to guide you in creating your own

Function MyMarkupPack
{   
    # MANDATORY
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

    # ====================================================
    #
    #           CUSTOMIZE FROM HERE ONWARDS
    #
    # ====================================================

    # Markup output formatting using search and replace queries against a string containing the entire markup content.

    $markupPack = @(
        ###############################################################
        #                           CONTENT                           #
        ###############################################################
        foreach ($attachmentCfg in $pageCfg['insertedAttachments']) {
            @{
                description = 'Change inserted attachment(s) filename references'
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape( $attachmentCfg['object'].preferredName )
                        replacement = "[$( $attachmentCfg['markdownFileName'] )]($( $pageCfg['mediaPathPandoc'] )/$( $attachmentCfg['markdownFileName'] ))"
                    }
                )
            }
        }
        @{
            description = 'Replace media (e.g. images, attachments) absolute paths with relative paths'
            replacements = @(
                @{
                    # E.g. 'C:/temp/notes/mynotebook/media/somepage-image1-timestamp.jpg' -> '../media/somepage-image1-timestamp.jpg'
                    searchRegex = [regex]::Escape("$( $pageCfg['mediaParentPathPandoc'] )/") # Add a trailing front slash
                    replacement = $pageCfg['levelsPrefix']
                }
            )
        }
        @{
            description = 'Add heading'
            replacements = @(
                @{
                    searchRegex = '^[^\r\n]*'
                    replacement = & {
                        $heading = "#+title:$( $pageCfg['object'].name )"
                        $creationDate = $pageCfg['lastModifiedTime']
                        $creationDay = $creationDate.DayOfWeek.ToString()
                        if ($config['headerTimestampEnabled']['value'] -eq 1) {
                            $heading += "`n#+CREATED: $( $creationDate.ToString('<yyyy-MM-dd') ) $( $creationDay.Substring(0, 3) ) $( $creationDate.ToString('HH:mm>') )"
                        }
                        $heading
                    }
                }
            )
        }

        # Check OrgPack1 and MarkdownPack1 for further examples

        ###############################################################
        #                          OPTIONAL                           #
        #       Optional substitutions based on config values         #
        ###############################################################

        # Check OrgPack1 and MarkdownPack1 for examples
        
        @{}

        ###############################################################
        #                    CONVERSION ARTIFACTS                     #
        #               Removal of conversion artifacts               #
        ###############################################################

        # Check OrgPack1 and MarkdownPack1 for examples

        @{}

    )

    $markupPack

}