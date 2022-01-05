# SPDX-License-Identifier: GPL-3.0

Function Format-MarkDown
{
    [CmdletBinding()]
    param (
        # Dryrun trigger
        [Parameter(Mandatory)]
        [object]
        $config
    ,
        # Converted page configuration object
        [Parameter(Mandatory)]
        [object]
        $pageCfg
    )

    # Pandoc Markdown output formatting. Each search and replace is done against a string containing the entire markdown content

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
                    $heading = "# $( $pageCfg['object'].name )"
                    if ($config['headerTimestampEnabled']['value'] -eq 1) {
                        $heading += "`n`nCreated: $(  $pageCfg['dateTime'].ToString('yyyy-MM-dd HH:mm:ss zz00') )"
                        $heading += "`n`nModified: $(  $pageCfg['lastModifiedTime'].ToString('yyyy-MM-dd HH:mm:ss zz00') )"
                        $heading += "`n`n---`n"
                    }
                    $heading
                }
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
                # Remove a newline between each occurrence of '- some list item'
                @{
                    searchRegex = '\r*\n\r*\n- '
                    replacement = "`n- "
                }
                # Remove all '>' occurrences immediately following bullet lists
                @{
                    searchRegex = '\n>[ ]*'
                    replacement = "`n"
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
        }else {
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
    }

}