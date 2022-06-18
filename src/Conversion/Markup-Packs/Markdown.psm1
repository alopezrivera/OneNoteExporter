# SPDX-License-Identifier: GPL-3.0

Function MarkdownPack1
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
                description = 'Generate attachment paths'
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
                    # ![](<ABSOLUTE_PATH/media/a page with spaces in its name-image1-timestamp.jpg>)
                    #                                    to:
                    #      ![](<**/media/a page with spaces in its name-image1-timestamp.jpg>)
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
                        $heading       = "# $( $pageCfg['object'].name )"
                        $creationDate  = $pageCfg['dateTime']
                        $creationDay   = $creationDate.DayOfWeek.ToString()
                        $creationMonth = (Get-Culture).DateTimeFormat.GetMonthName([int]$pageCfg['lastModifiedTime'].ToString('MM'))
                        if ($config['headerTimestamp']['value'] -eq 1) {
                            $heading += "`n`n$( $creationDay ), $( $creationMonth ) $( $pageCfg['lastModifiedTime'].ToString('d, yyyy') ) $('`')$( $pageCfg['lastModifiedTime'].ToString('HH:mm') )$('`')"
                            $heading += "`n`n---"
                        }
                        $heading
                    }
                }
            )
        }
        @{
            description = 'Refactor numbered list bullet points'
            replacements = @(
                @{
                    searchRegex = '(?<=\n\s*)([a-zA-Z0-9]{1,})(?=[.]\s*)'
                    replacement = '1'
                }
            )
        }
        ###############################################################
        #                     CONVERSION ARTIFACTS                    #
        ###############################################################
        @{
            description = 'Remove unwated whitespace, newlines, over-indentation and more'
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
                # Replace multiple spaces after list items
                @{
                    searchRegex = '(?<=\n\s*- )([ \s\t]{1,})(?=.*?\n)'
                    replacement = ''
                }
                @{
                    searchRegex = '(?<=\n\s*)([0-9]+. [ \s\t]{1,})(?=.*?\n)'
                    replacement = '1. '             # Take chance to replace numbered list indices for '1.'
                }
                # Remove extra whitespace after list item markers
                @{
                    searchRegex = '(?<=\n\s*- )([ \s\t]{1,})(?=.*?\n)'
                    replacement = ''
                }
                @{
                    searchRegex = '(?<=\n\s*- )([ \s\t]{1,})(?=.*?\n)'
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
                    searchRegex = '\n(?=\n!\[.*?\]\(.*?\))'
                    replacement = ''
                }
                # Remove extra newline before inline tables
                @{
                    searchRegex = '\n(?=\n\|.*?\|)'
                    replacement = ''
                }
                # Remove over-indentation of list items
                @{
                    # When regex doesn't cut it
                    postprocessing = {

                        $content = $args[0]
                        $lines = $content.Split("`n")
                        
                        # Create new content string
                        $new = $lines[0]
                        # For each line in the output
                        $prevline = $new

                        # For each line in the content string
                        foreach ($line in $lines[1..($lines.Length-1)]) {
                            
                            # First, match list item indents
                            $m = $line -match "^\s{2,}(?=[-0-9\.]{1,})"
                            
                            # If there's an indented list item in the line
                            if ($m) {
                                # Retrieve the list item indent string
                                $match = $Matches[0]
                                # Replace it with a new indent string with a base indent of 2 for unnumbered and 3 for numbered lists
                                $baseIndent = if ($line -match "^\s{2,}(?=[0-9\.]{1,})") {
                                    3       # For numbered list items
                                }else{
                                    2       # For unnumbered list items
                                }
                                $replacement = " " * $baseIndent * ($match.length/4)
                                # Replace the indent string with our new one
                                $line = $line -replace "\s{2,}(?=[-0-9\.]{1,})", $replacement
                            }else{

                                # Else, there may still be an indented paragraph in the line

                                # Match list indented paragraph indents
                                $pm = $line -match "^\s{2,}"
                                
                                if ($pm) {
                                    # Retrieve the indent string
                                    $match = $Matches[0]
                                    # Replace it with a new indent string, its base indent determined by the previous line (where we expect to find the paragraph's parent list item)
                                    #   The beginning of the string may or *may not* be indented, as the paragraph could be indented under a non-indented list item
                                    #       ^\s{2,} -> ^\s*
                                    $baseIndent = if ($prevline -match "^\s*(?=[0-9\.]{1,})") {
                                        3       # For numbered list items
                                    }else{
                                        2       # For unnumbered list items
                                    }
                                    $replacement = " " * $baseIndent * ($match.length/4)
                                    # Replace the indent string with our new one
                                    $line = $line -replace "\s{2,}", $replacement
                                }

                            }

                            # Append line to new content string
                            $new = $new + "`n" + $line
                            # Save previous line
                            $prevline = $line
                        }

                        $new

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
                description = "Clear all '\' characters"
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
                description = "Clear all '\' characters except those preceding alphanumeric characters"
                replacements = @(
                    @{
                        searchRegex = '\\([^A-Za-z0-9])'
                        replacement = '$1'
                    }
                )
            }
        }
    )

    $markupPack

}