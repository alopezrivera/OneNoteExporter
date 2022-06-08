# SPDX-License-Identifier: GPL-3.0

Function Get-DefaultConfiguration {
    [CmdletBinding()]
    param ()

    # The default configuration
    $config = [ordered]@{
        dryRun = @{
            description = @'
Whether to do a dry run
1: Convert - Default
2: Convert (dry run)
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        notesDestPath = @{
            description = @'
Specify folder path that will contain your resulting Notes structure - Default: c:\temp\notes
'@
            default = 'c:\temp\notes'
            value = 'c:\temp\notes'
            validateOptions = 'directoryexists'
        }
        targetNotebook = @{
            description = @'
Specify a notebook name to convert
'': Convert all notebooks - Default
'mynotebook': Convert specific notebook named 'mynotebook'
'@
            default = ''
            value = ''
        }
        docxReuse = @{
            description = @'
Whether to create new word .docx or reuse existing ones
1: Use existing .docx files (90% faster)
2: Always create new .docx files - Default
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        docxKeep = @{
            description = @'
Whether to discard word .docx after conversion
1: Discard intermediate .docx files - Default
2: Keep .docx files
'@
            default = 2
            value = 2
            validateRange = 1,2
        }
        docxNamingConvention = @{
            description = @'
Whether to use name .docx files using page ID with last modified date epoch, or hierarchy
1: Use page ID with last modified date epoch (recommended if you chose to use existing .docx files) - Default
2: Use hierarchy
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        prefixFolders = @{
            description = @'
Whether to use prefix vs subfolders
1: Create folders for subpages (e.g. Page\Subpage.<ext>) - Default
2: Add prefixes for subpages (e.g. Page_Subpage.<ext>)
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        muFileNameAndFolderNameMaxLength = @{
            description = @'
Specify a value between 32 and 255 as the maximum length of markdown file names, and their folder names (only when using subfolders for subpages (e.g. Page\Subpage.md)). File and folder names with length exceeding this value will be truncated accordingly.
NOTE: If you are using prefixes for subpages (e.g. Page_Subpage.md), it is recommended to set this to at 100 or more.
Default: 32
'@
            default = 255
            value = 255
            validateRange = 32,255
        }
        mediaLocation = @{
            description = @'
Whether to store media in single or multiple folders
1: Separate 'media' folder for each folder in the hierarchy - Default
2: Images stored in single 'media' folder at Notebook-level
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        conversion = @{
            description = @'
Specify Pandoc output format and optional extensions in the format: <format><+extension><-extension>. See: https://pandoc.org/MANUAL.html#options
Examples:
  markdown-simple_tables-multiline_tables-grid_tables+pipe_tables
  commonmark+pipe_tables
  gfm+pipe_tables
  markdown_mmd-simple_tables-multiline_tables-grid_tables+pipe_tables
  markdown_phpextra-simple_tables-multiline_tables-grid_tables+pipe_tables
  markdown_strict+simple_tables-multiline_tables-grid_tables+pipe_tables
Default:
  markdown-simple_tables-multiline_tables-grid_tables+pipe_tables
'@
            default = 'org-simple_tables-multiline_tables-grid_tables+pipe_tables'
            value = 'org-simple_tables-multiline_tables-grid_tables+pipe_tables'
        }
        markupPack = @{
            description = @'
# Specify a custom Markup Pack to override default
# Options:
#   <empty string>      - Process with default Markup Pack
#   none                - Don't apply any post-processing (for debugging purposes)
#   OrgPack1            - Org Mode pack shipping with OneWayOut
#   MarkdownPack1       - Markdown pack shipping with OneWayOut
'@
            default = ''
            value = ''
        }
        headerTimestamp = @{
            description = @'
Whether to include page timestamp and separator at top of document
1: Include - Default
2: Don't include
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        keepEscape = @{
            description = @'
Whether to remove escape symbols from markup files. See: https://pandoc.org/MANUAL.html#backslash-escapes
1: Remove all '\' characters  - Default
2: Remove all '\' characters except those preceding alphanumeric characters
3: Keep '\' symbol escape
'@
            default = 1
            value = 1
            validateRange = 1,3
        }
        keepEmptyListItems = @{
            description = @'
Whether to delete empty list items in your notes.
1: Remove empty list items  - Default
2: Keep empty list items
'@
            default = 1
            value = 1
            validateRange = 1,3
        }
        newlineCharacter = @{
            description = @'
Whether to use Line Feed (LF) or Carriage Return + Line Feed (CRLF) for new lines
1: LF (unix) - Default
2: CRLF (windows)
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
        exportPDF = @{
            description = @'
Whether to include a PDF export alongside the markdown file
1: Don't include PDF - Default
2: Include PDF
'@
            default = 1
            value = 1
            validateRange = 1,2
        }
    }

    $config
    
}