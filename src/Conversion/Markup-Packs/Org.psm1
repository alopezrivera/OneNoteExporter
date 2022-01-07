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
                        $creationDate = $pageCfg['dateTime']
                        $creationDay = $creationDate.DayOfWeek.ToString()
                        if ($config['headerTimestampEnabled']['value'] -eq 1) {
                            $heading += "`n#+CREATED: $( $creationDate.ToString('<yyyy-MM-dd') ) $( $creationDay.Substring(0, 3) ) $( $creationDate.ToString('HH:mm>') )"
                        }
                        $heading
                    }
                }
            )
        }
        @{
            description = 'Separate numbered and unnumbered lists'
            replacements = @(
                @{
                    searchRegex = '(?<=\n[0-9]+. .*?)(\n)(?=\n-)'
                    replacement = "`n`n"
                }
                @{
                    searchRegex = '(?<=\n- .*?)(\n)(?=\n[0-9]+.)'
                    replacement = "`n`n"
                }
            )
        }
        if ($config['keepspaces']['value'] -eq 1 ) {
            @{
                description = 'Clear double spaces from bullets and non-breaking spaces spaces from blank lines'
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape([char]0x00A0)
                        replacement = ''
                    }
                    # Remove triple spaces
                    @{
                        searchRegex = '(?<=\n)(\n)(?=\n)'
                        replacement = ''
                    }
                    # Remove double newlines after unnumbered list items
                    @{
                        searchRegex = '(?<=\n\s*- .*?)(\n)(?=\n\s*-)'
                        replacement = ''
                    }
                    # Remove double newlines after numbered list items
                    @{
                        searchRegex = '(?<=\n\s*[0-9]+. .*?)(\n)(?=\n\s*[0-9]+.)'
                        replacement = ''
                    }
                    # Remove double newlines after indented paragraphs
                    @{
                        searchRegex = '(?<=\n\s{2,}[^-0-9\.]*?)(\n)(?=\n)'
                        replacement = ''
                    }
                    # Remove all '>' occurrences immediately following bullet lists
                    @{
                        searchRegex = '\n>[ ]*'
                        replacement = "`n"
                    }
                    # Remove extra newline before inline pictures
                    @{
                        searchRegex = '\n(?=\n\[\[.*?\]\])'
                        replacement = ''
                    }
                    # Remove extra newline before inline tables
                    @{
                        searchRegex = '\n(?=\n\|.*?\|)'
                        replacement = ''
                    }
                )
            }
        }
        if ($config['keepescape']['value'] -eq 1) {
            @{
                description = "Clear all '\' characters"
                replacements = @(
                    @{
                        searchRegex = [regex]::Escape('\')
                        replacement = ''
                    }
                )
            }
        }
        elseif ($config['keepescape']['value'] -eq 2) {
            @{
                description = "Clear all '\' characters except those preceding alphanumeric characters"
                replacements = @(
                    @{
                        searchRegex = '\\([^A-Za-z0-9])'
                        replacement = '$1'
                    }
                )
            }
        }
        & {
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
            else {
                @{
                    description = "Use CRLF for newlines"
                    replacements = @(
                        @{
                            searchRegex = '\r*\n'
                            replacement = "`r`n"
                        }
                    )
                }
            }
            # Remove any empty QUOTEs
            @{
                description = 'Remove empty QUOTES'
                replacements = @(
                    @{
                        searchRegex = '\n#\+BEGIN_QUOTE\n\s*\n#\+END_QUOTE'
                        replacement = ''
                    }
                )
            }
        }
        
    )

    $markupPack

}