# SPDX-License-Identifier: GPL-3.0

Function OrgPack1
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
            description = 'Replace media (eg: images, attachments) absolute paths with relative paths'
            replacements = @(
                @{
                    # eg: 'C:/temp/notes/mynotebook/media/somepage-image1-timestamp.jpg' -> '../media/somepage-image1-timestamp.jpg'
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
                        $creationDate = $pageCfg['dateTime']
                        $creationDay = $creationDate.DayOfWeek.ToString()
                        if ($config['headerTimestamp']['value'] -eq 1) {
                            $heading += "`n#+CREATED: $( $creationDate.ToString('<yyyy-MM-dd') ) $( $creationDay.Substring(0, 3) ) $( $creationDate.ToString('HH:mm>') )`n`n"
                        }
                        $heading
                    }
                }
            )
        }
        ###############################################################
        #                          OPTIONAL                           #
        ###############################################################
        if ($config['keepEmptyListItems']['value'] -eq 1) {
            @{
                description = 'Remove empty list items'
                replacements = @(
                    @{
                        searchRegex = "\n[ ]*- $([char]0x00A0)\n"
                        replacement = ''
                    }
                    @{
                        searchRegex = "\n[ ]*[0-9]+. $([char]0x00A0)\n"
                        replacement = ''
                    }
                )
            }
        }
        if ($config['newlineCharacter']['value'] -eq 1) {
            @{
                description = "Use LF for newlines"
                replacements = @(
                    @{
                        searchRegex = '\r*\n'
                        replacement = "`n"
                    }
                )
            }
        }
        if ($config['keepEscape']['value'] -eq 1) {
            @{
                description = "Remove all '\' characters"
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape('\')
                        replacement = ''
                    }
                )
            }
        }
        elseif ($config['keepEscape']['value'] -eq 2) {
            @{
                description = "Remove all '\' characters except those preceding alphanumeric characters"
                replacements = @(
                    @{
                        searchRegex = '\\([^A-Za-z0-9])'
                        replacement = '$1'
                    }
                )
            }
        }
        ###############################################################
        #                     CONVERSION ARTIFACTS                    #
        ###############################################################
        @{
            description = 'Remove extra newline after list items and indented paragraphs'
            replacements = @(
                # Remove double newlines within unordered lists
                @{
                    searchRegex = '(?<=\n[ ]*- .*?)(\n)(?=\n[ ]*-)'
                    replacement = ''
                }
                # Remove double newlines within ordered lists
                @{
                    searchRegex = '(?<=\n[ ]*[0-9]+. .*?)(\n)(?=\n[ ]*[0-9]+.)'
                    replacement = ''
                }
                # Remove double newlines after indented paragraphs
                @{
                    searchRegex = '(?<=[ ]{2,}([^- 0-9.\n]{2}).*\n)(\n)(\n*)'
                    replacement = '$3'
                }
            )
        }
        @{
           description = 'Remove non-breaking spaces from blank lines'
           replacements = @(
                @{
                    searchRegex = "(?<=\n)($([char]0x00A0)\n\n)"
                    replacement = ''
                }
            )
        }
        @{
            description = 'Remove empty QUOTES'
            replacements = @(
                @{
                    searchRegex = '\n#\+BEGIN_QUOTE\n\s*\n#\+END_QUOTE'
                    replacement = ''
                }
            )
        }
    )

    $markupPack

}