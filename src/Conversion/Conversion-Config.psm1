# SPDX-License-Identifier: GPL-3.0

# Import Markup Pack utilities
Import-Module .\src\Conversion\Conversion-Markup.psm1

# Import Markup Packs
Import-Module .\src\Conversion\Markup-Packs\Org.psm1
Import-Module .\src\Conversion\Markup-Packs\Markdown.psm1

Function Encode-Markdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0, ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string]
        $Name
    ,
        [Parameter()]
        [switch]
        $Uri
    )

    if ($Uri) {
        $markdownChars = '[]()'.ToCharArray()
        foreach ($c in $markdownChars) {
            $Name = $Name.Replace("$c", "\$c")
        }
    }else {
        # See: https://pandoc.org/MANUAL.html#backslash-escapes
        $markdownChars = '\*_{}[]()#+-.!'.ToCharArray()
        foreach ($c in $markdownChars) {
            $Name = $Name.Replace("$c", "\$c")
        }
        $markdownChars2 = '`'
        foreach ($c in $markdownChars2) {
            $Name = $Name.Replace("$c", "$c$c$c")
        }
    }
    $Name
}

Function New-SectionGroupConversionConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $OneNoteConnection
    ,
        # The desired directory to store any converted Page(s) found in this Section Group's Section(s)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NotesDestination
    ,
        [Parameter(Mandatory)]
        [object]
        $Config
    ,
        # Section Group XML object(s)
        [Parameter(Mandatory)]
        [array]
        $SectionGroups
    ,
        [Parameter(Mandatory)]
        [int]
        $LevelsFromRoot
    ,
        [Parameter()]
        [switch]
        $AsArray
    )

    $sectionGroupConversionConfig = [System.Collections.ArrayList]@()

    # Build an object representing the conversion of a Section Group (treat a Notebook as a Section Group, it is no different)
    foreach ($sectionGroup in $SectionGroups) {
        # Skip over Section Groups in recycle bin
        if ((Get-Member -InputObject $sectionGroup -Name 'isRecycleBin') -and $sectionGroup.isRecycleBin -eq 'true') {
            continue
        }

        $cfg = [ordered]@{}

        if ($LevelsFromRoot -eq 0) {
            "`nBuilding conversion configuration for $( $sectionGroup.name ) [Notebook]" | Write-Host -ForegroundColor DarkGreen
        }else {
            "`n$( '#' * ($LevelsFromRoot) ) Building conversion configuration for $( $sectionGroup.name ) [Section Group]" | Write-Host -ForegroundColor DarkGray
        }

        # Build this Section Group
        $cfg = [ordered]@{}
        $cfg['object'] = $sectionGroup # Keep a reference to the SectionGroup object
        $cfg['kind'] = 'SectionGroup'
        $cfg['id'] = $sectionGroup.ID # E.g. {9570CCF6-17C2-4DCE-83A0-F58AE8914E29}{1}{B0}
        $cfg['nameCompat'] = $sectionGroup.name | Remove-InvalidFileNameChars
        $cfg['levelsFromRoot'] = $LevelsFromRoot
        $cfg['uri'] = $sectionGroup.path # E.g. https://d.docs.live.net/0123456789abcdef/Skydrive Notebooks/mynotebook/mysectiongroup
        $cfg['notesDirectory'] = [io.path]::combine( $NotesDestination.TrimEnd('/').TrimEnd('\').Replace('\', [io.path]::DirectorySeparatorChar), $cfg['nameCompat'] ) # No need to truncate. Section Group and Section names have a max length of 50, so we should never hit the absolute path, file name, or directory name limits on Windows
        $cfg['notesBaseDirectory'] = & {
            # E.g. 'c:\temp\notes\mynotebook\mysectiongroup'
            # E.g. levelsFromRoot: 1
            $split = $cfg['notesDirectory'].Split( [io.path]::DirectorySeparatorChar )
            # E.g. 5
            $totalLevels = $split.Count
            # E.g. 0..(5-1-1) -> 'c:\temp\notes\mynotebook'
            $split[0..($totalLevels - $cfg['levelsFromRoot'] - 1)] -join [io.path]::DirectorySeparatorChar
        }
        $cfg['notebookName'] = Split-Path $cfg['notesBaseDirectory'] -Leaf
        $cfg['pathFromRoot'] = $cfg['notesDirectory'].Replace($cfg['notesBaseDirectory'], '').Trim([io.path]::DirectorySeparatorChar)
        $cfg['pathFromRootCompat'] = $cfg['pathFromRoot'] | Remove-InvalidFileNameChars
        $cfg['notesDocxDirectory'] = [io.path]::combine( $cfg['notesBaseDirectory'], 'docx' )
        $cfg['directoriesToCreate'] = @()

        # Build this Section Group's sections
        $cfg['sections'] = [System.Collections.ArrayList]@()

        if (! (Get-Member -InputObject $sectionGroup -Name 'Section') -and ! (Get-Member -InputObject $sectionGroup -Name 'SectionGroup') ) {
            "Ignoring empty Section Group: $( $cfg['pathFromRoot'] )" | Write-Host -ForegroundColor DarkGray
        }

        if (Get-Member -InputObject $sectionGroup -Name 'Section') {
            foreach ($section in $sectionGroup.Section) {
                "$( '#' * ($LevelsFromRoot + 1) ) Building conversion configuration for $( $section.name ) [Section]" | Write-Host -ForegroundColor DarkGray

                $sectionCfg = [ordered]@{}
                $sectionCfg['notebookName'] = $cfg['notebookName']
                $sectionCfg['notesBaseDirectory'] = $cfg['notesBaseDirectory']
                $sectionCfg['notesDirectory'] = $cfg['notesDirectory']
                $sectionCfg['sectionGroupUri'] = $cfg['uri'] # Keep a reference to my Section Group Configuration object's uri
                $sectionCfg['sectionGroupName'] = $cfg['object'].name
                $sectionCfg['object'] = $section # Keep a reference to the Section object
                $sectionCfg['kind'] = 'Section'
                $sectionCfg['id'] = $section.ID # E.g {BE566C4F-73DC-43BD-AE7A-1954F8B22C2A}{1}{B0}
                $sectionCfg['nameCompat'] = $section.name | Remove-InvalidFileNameChars
                $sectionCfg['levelsFromRoot'] = $cfg['levelsFromRoot'] + 1
                $sectionCfg['pathFromRoot'] = "$( $cfg['pathFromRoot'] )$( [io.path]::DirectorySeparatorChar )$( $sectionCfg['nameCompat'] )".Trim([io.path]::DirectorySeparatorChar) # No need to truncate. Section Group and Section names have a max length of 50, so we should never hit the absolute path, file name, or directory name limits on Windows
                $sectionCfg['pathFromRootCompat'] = $sectionCfg['pathFromRoot'] | Remove-InvalidFileNameChars
                $sectionCfg['uri'] = $section.path # E.g. https://d.docs.live.net/0123456789abcdef/Skydrive Notebooks/mynotebook/mysectiongroup/mysection
                $sectionCfg['lastModifiedTime'] = [Datetime]::ParseExact($section.lastModifiedTime, 'yyyy-MM-ddTHH:mm:ss.fffZ', $null)
                $sectionCfg['lastModifiedTimeEpoch'] = [int][double]::Parse((Get-Date ((Get-Date $sectionCfg['lastModifiedTime']).ToUniversalTime()) -UFormat %s)) # Epoch

                $sectionCfg['pages'] = [System.Collections.ArrayList]@()

                # Build Section's pages
                if (Get-Member -InputObject $section -Name 'Page') {
                    foreach ($page in $section.Page) {
                        "$( '#' * ($LevelsFromRoot + 2) ) Building conversion configuration for $( $page.name ) [Page]" | Write-Host -ForegroundColor DarkGray

                        $previousPage = if ($sectionCfg['pages'].Count -gt 0) { $sectionCfg['pages'][$sectionCfg['pages'].Count - 1] } else { $null }
                        $pageCfg = [ordered]@{}
                        $pageCfg['notebookName'] = $cfg['notebookName']
                        $pageCfg['notesBaseDirectory'] = $cfg['notesBaseDirectory']
                        $pageCfg['notesDirectory'] = $cfg['notesDirectory']
                        $pageCfg['sectionGroupUri'] = $cfg['uri'] # Keep a reference to mt Section Group Configuration object's uri
                        $pageCfg['sectionGroupName'] = $cfg['object'].name
                        $pageCfg['sectionUri'] = $sectionCfg['uri'] # Keep a reference to my Section Configuration object's uri
                        $pageCfg['sectionName'] = $sectionCfg['object'].name
                        $pageCfg['object'] = $page # Keep a reference to my Page object
                        $pageCfg['kind'] = 'Page'
                        $pageCfg['id'] = $page.ID # E.g. {3D017C7D-F890-4AC8-A094-DEC1163E7B85}{1}{E19461971475288592555920101886406896686096991}
                        $pageCfg['nameCompat'] = $page.name | Remove-InvalidFileNameChars
                        $pageCfg['levelsFromRoot'] = $sectionCfg['levelsFromRoot']
                        $pageCfg['pathFromRoot'] = "$( $sectionCfg['pathFromRoot'] )$( [io.path]::DirectorySeparatorChar )$( $pageCfg['nameCompat'] )"
                        $pageCfg['pathFromRootCompat'] = $pageCfg['pathFromRoot'] | Remove-InvalidFileNameChars
                        $pageCfg['uri'] = "$( $sectionCfg['object'].path )/$( $page.name )" # There's no $page.path property, so we generate one. E.g. https://d.docs.live.net/0123456789abcdef/Skydrive Notebooks/mynotebook/mysectiongroup/mysection/mypage
                        $pageCfg['dateTime'] = [Datetime]::ParseExact($page.dateTime, 'yyyy-MM-ddTHH:mm:ss.fffZ', $null)
                        $pageCfg['lastModifiedTime'] = [Datetime]::ParseExact($page.lastModifiedTime, 'yyyy-MM-ddTHH:mm:ss.fffZ', $null)
                        $pageCfg['lastModifiedTimeEpoch'] = [int][double]::Parse((Get-Date ((Get-Date $pageCfg['lastModifiedTime']).ToUniversalTime()) -UFormat %s)) # Epoch
                        $pageCfg['pageLevel'] = $page.pageLevel -as [int]
                        $pageCfg['conversion'] = $config['conversion']['value']
                        $pageCfg['pagePrefix'] = & {
                            # 9 different scenarios
                            if ($pageCfg['pageLevel'] -eq 1) {
                                # 1 -> 1, 2 -> 1, or 3 -> 1
                                ''
                            }else {
                                if ($previousPage) {
                                    if ($previousPage['pageLevel'] -lt $pageCfg['pageLevel']) {
                                        # 1 -> 2, 1 -> 3, or 2 -> 3
                                        "$( $previousPage['filePathRel'] )$( [io.path]::DirectorySeparatorChar )"
                                    }elseif ($previousPage['pageLevel'] -eq $pageCfg['pageLevel']) {
                                        # 2 -> 2, or 3 -> 3
                                        "$( Split-Path $previousPage['filePathRel'] -Parent )$( [io.path]::DirectorySeparatorChar )"
                                    }else {
                                        # 3 -> 2 (or 4 -> 2, but 4th level subpages don't exist, but technically this supports it)
                                        $split = $previousPage['filePathRel'].Split([io.path]::DirectorySeparatorChar)
                                        $index = $pageCfg['pageLevel'] - 1 - 1 # If page level n, the prefix should be n-1
                                        if ($index -lt 0) {
                                            $index = 0 # The shallowest subpage must be a child of a first level page, i.e. $split[0]
                                        }
                                        "$( $split[0..$index] -join [io.path]::DirectorySeparatorChar )$( [io.path]::DirectorySeparatorChar )"
                                    }
                                }else {
                                    '' # Should never end up here
                                }
                            }
                        }
                        # Win32 path limits. E.g. 'C:\path\to\file' or 'C:\path\to\folder'
                        #   Absolute path:
                        #   - Win32: Max 259 characters for files, Max 247 characters for directories.
                        #   File or directory name:
                        #   - Max 255 characters long for file or folder names
                        # Non-Win32 path limits. E.g. '\\?\C:\path\to\file' or '\\?\C:\path\to\folder'. Prefixing with '\\?\' allows Windows Powershell <= 5 (based on Win32) to support long absolute paths.
                        #   Absolute path:
                        #   - N.A.
                        #   File or directory name:
                        #   - Max 255 characters long for file or folder names
                        # See: https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file?redirectedfrom=MSDN#maxpath
                        
                        # Get markup file extension
                        $extension = Get-MarkupExtension $pageCfg

                        # Normalize the final markup file path. Page names can be very long, and can exceed the max absolute path length, or max file or folder name on a Windows system.
                        $pageCfg['filePathRel'] = & {
                            $filePathRel = "$( $pageCfg['pagePrefix'] )$( $pageCfg['nameCompat'] )"

                            # in case multiple pages with the same name exist in a section, postfix the filename
                            $recurrence = 0
                            foreach ($p in $sectionCfg['pages']) {
                                if ($p['pagePrefix'] -eq $pageCfg['pagePrefix'] -and $p['pathFromRoot'] -eq $pageCfg['pathFromRoot']) {
                                    $recurrence++
                                }
                            }
                            if ($recurrence -gt 0) {
                                $filePathRel = "$filePathRel-$recurrence"
                            }
                            $filePathRel | Truncate-PathFileName -Length $config['muFileNameAndFolderNameMaxLength']['value'] # Truncate to no more than 255 characters so we don't hit the folder name limit on most file systems on Windows / Linux
                        }
                        $pageCfg['filePathRelUnderscore'] = $pageCfg['filePathRel'].Replace( [io.path]::DirectorySeparatorChar, '_' )
                        $pageCfg['filePathNormal'] = & {
                            $pathWithoutExtension = 
                            
                            # If note hierarchy is to be prefixed to note name:
                            if ($config['prefixFolders']['value'] -eq 2) 
                            {
                                [io.path]::combine( $cfg['notesDirectory'], $sectionCfg['nameCompat'], "$( $pageCfg['filePathRelUnderscore'] )" )
                            }
                            # If note hierarchy is to be turned into a directory structure:
                            else 
                            {
                                [io.path]::combine( $cfg['notesDirectory'], $sectionCfg['nameCompat'], "$( $pageCfg['filePathRel'] )" )
                            }

                            "$( $pathWithoutExtension | Truncate-PathFileName -Length ($config['muFileNameAndFolderNameMaxLength']['value'] - 3) ).$($extension)" # Truncate to no more than 255 characters so we don't hit the file name limit on Windows / Linux
                        }
                        $pageCfg['filePathLong'] = "\\?\$( $pageCfg['filePathNormal'] )" # A non-Win32 path. Prefixing with '\\?\' allows Windows Powershell <= 5 (based on Win32) to support long absolute paths.
                        $pageCfg['filePath'] = if ($PSVersionTable.PSVersion.Major -le 5) {
                            $pageCfg['filePathLong'] # Add support for long paths on Powershell 5
                        }else {
                            $pageCfg['filePathNormal'] # Powershell Core supports long file paths
                        }
                        $pageCfg['fileDirectory'] = Split-Path $pageCfg['filePathNormal'] -Parent
                        $pageCfg['fileName'] = Split-Path $pageCfg['filePathNormal'] -Leaf
                        $pageCfg['fileExtension'] = if ($pageCfg['filePathNormal'] -match '(\.[^.]+)$') { $matches[1] } else { '' }
                        $pageCfg['fileBaseName'] = $pageCfg['fileName'] -replace "$( [regex]::Escape($pageCfg['fileExtension']) )$", ''
                        $pageCfg['pdfExportFilePathTmp'] = [io.path]::combine( (Split-Path $pageCfg['filePath'] -Parent ), "$( $pageCfg['id'] )-$( $pageCfg['lastModifiedTimeEpoch'] ).pdf" ) # Publishing a .pdf seems to be limited to 204 characters. So we will export the .pdf to a unique file name, then rename it to the actual name
                        $pageCfg['pdfExportFilePath'] = if ( ($pageCfg['fileName'].Length + ('.pdf'.Length - ".$($extension)".Length)) -le $config['muFileNameAndFolderNameMaxLength']['value']) {
                            $pageCfg['filePath'] -replace "\.$($extension)$", '.pdf'
                        }else {
                            $pageCfg['filePath'] -replace ".\.$($extension)$", '.pdf' # Trim 1 character in the basename when replacing the extension
                        }
                        $pageCfg['levelsPrefix'] = if ($config['medialocation']['value'] -eq 2) {
                            ''
                        }else {
                            if ($config['prefixFolders']['value'] -eq 2) {
                                "$( '../' * ($pageCfg['levelsFromRoot'] + 1 - 1) )"
                            }else {
                                "$( '../' * ($pageCfg['levelsFromRoot'] + $pageCfg['pageLevel'] - 1) )"
                            }
                        }
                        $pageCfg['tmpPath'] = & {
                            $dateNs = Get-Date -Format "yyyy-MM-dd-HH-mm-ss-fffffff"
                            if ($env:OS -match 'windows') {
                                [io.path]::combine($env:TEMP, $cfg['notebookName'], $dateNs)
                            }else {
                                [io.path]::combine('/tmp', $cfg['notebookName'], $dateNs)
                            }
                        }
                        $pageCfg['mediaParentPath'] = if ($config['medialocation']['value'] -eq 2) {
                            $pageCfg['fileDirectory']
                        }else {
                            $cfg['notesBaseDirectory']
                        }
                        $pageCfg['mediaPath'] = [io.path]::combine( $pageCfg['mediaParentPath'], 'media' )
                        $pageCfg['mediaParentPathPandoc'] = [io.path]::combine( $pageCfg['tmpPath'] ).Replace( [io.path]::DirectorySeparatorChar, '/' ) # Pandoc outputs paths in markdown with with front slahes after the supplied <mediaPath>, e.g. '<mediaPath>/media/image.png'. So let's use a front-slashed supplied mediaPath
                        $pageCfg['mediaPathPandoc'] = [io.path]::combine( $pageCfg['tmpPath'], 'media').Replace( [io.path]::DirectorySeparatorChar, '/' ) # Pandoc outputs paths in markdown with with front slahes after the supplied <mediaPath>, e.g. '<mediaPath>/media/image.png'. So let's use a front-slashed supplied mediaPath
                        $pageCfg['docxExportFilePath'] = if ($config['docxNamingConvention']['value'] -eq 1) {
                            [io.path]::combine( $cfg['notesDocxDirectory'], "$( $pageCfg['id'] )-$( $pageCfg['lastModifiedTimeEpoch'] ).docx" )
                        }else {
                            [io.path]::combine( $cfg['notesDocxDirectory'], "$( $pageCfg['pathFromRootCompat'] ).docx" )
                        }
                        $pageCfg['insertedAttachments'] = @(
                            & {
                                $pagexml = Get-OneNotePageContent -OneNoteConnection $OneNoteConnection -PageId $pageCfg['object'].ID

                                # Get any attachment(s) found in pages
                                if (Get-Member -InputObject $pagexml -Name 'Page') {
                                    if (Get-Member -InputObject $pagexml.Page -Name 'Outline') {
                                        $insertedFiles = $pagexml.Page.Outline.OEChildren.OE | Where-Object { $null -ne $_ -and (Get-Member -InputObject $_ -Name 'InsertedFile') } | ForEach-Object { $_.InsertedFile }
                                        foreach ($i in $insertedFiles) {
                                            $attachmentCfg = [ordered]@{}
                                            $attachmentCfg['object'] =  $i
                                            $attachmentCfg['nameCompat'] =  $i.preferredName | Remove-InvalidFileNameCharsInsertedFiles
                                            $attachmentCfg['markdownFileName'] =  $attachmentCfg['nameCompat'] | Encode-Markdown -Uri
                                            $attachmentCfg['source'] =  $i.pathCache
                                            $attachmentCfg['destination'] =  [io.path]::combine( $pageCfg['mediaPath'], $attachmentCfg['nameCompat'] )

                                            $attachmentCfg
                                        }
                                    }
                                }
                            }
                        )

                        # Choose the default Markup Pack for the format being converted to, or any other manually specified in config.sp1 if that is the case
                        $markupPack = Get-MarkupPack $config $pageCfg
                        $pageCfg['mutations'] = &$markupPack $config $pageCfg

                        # The directories to be created. These directories should never hit the absolute path, file name, or directory name limits on Windows
                        $pageCfg['directoriesToCreate'] = @(
                            @(
                                $cfg['notesDocxDirectory']
                                $cfg['notesDirectory']
                                $pageCfg['tmpPath']
                                $pageCfg['fileDirectory']
                                $pageCfg['mediaPath']
                            ) | Select-Object -Unique
                        )
                        # Directories to delete
                        $pageCfg['directoriesToDelete'] = @(
                            $pageCfg['tmpPath']
                        )
                        # Directory separation character
                        $pageCfg['directorySeparatorChar'] = [io.path]::DirectorySeparatorChar

                        # Populate the pages array (needed even when -AsArray switch is not on, because we need this section's pages' state to know whether there are duplicate page names)
                        $sectionCfg['pages'].Add( $pageCfg ) > $null

                        if (!$AsArray) {
                            # Send the configuration immediately down the pipeline
                            $pageCfg
                        }
                    }
                }else {
                    "Ignoring empty Section: $( $sectionCfg['pathFromRoot'] )" | Write-Host -ForegroundColor DarkGray
                }

                # Populate the sections array
                if ($AsArray) {
                    $cfg['sections'].Add( $sectionCfg ) > $null
                }
            }
        }

        $cfg['sectionGroups'] = [System.Collections.ArrayList]@()

        # Build this Section Group's Section Groups
        if ((Get-Member -InputObject $sectionGroup -Name 'SectionGroup')) {
            if ($AsArray) {
                $cfg['sectionGroups'] = New-SectionGroupConversionConfig -OneNoteConnection $OneNoteConnection -NotesDestination $cfg['notesDirectory'] -Config $Config -SectionGroups $sectionGroup.SectionGroup -LevelsFromRoot ($LevelsFromRoot + 1) -AsArray:$AsArray
            }else {
                # Send the configuration immediately down the pipeline
                New-SectionGroupConversionConfig -OneNoteConnection $OneNoteConnection -NotesDestination $cfg['notesDirectory'] -Config $Config -SectionGroups $sectionGroup.SectionGroup -LevelsFromRoot ($LevelsFromRoot + 1)
            }
        }

        # Populate the conversion config
        if ($AsArray) {
            $sectionGroupConversionConfig.Add( $cfg ) > $null
        }
    }

    # Return the final conversion config
    if ($AsArray) {
        ,$sectionGroupConversionConfig # This syntax is needed to send an array down the pipeline without it being unwrapped. (It works by wrapping it in an array with a null sibling)
    }
}