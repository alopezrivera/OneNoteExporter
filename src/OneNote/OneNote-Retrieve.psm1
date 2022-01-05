# SPDX-License-Identifier: GPL-3.0

Function Get-OneNoteHierarchy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]
        $OneNoteConnection
    )

    # Open OneNote hierarchy
    [xml]$hierarchy = ""
    $OneNoteConnection.GetHierarchy("", [Microsoft.Office.InterOp.OneNote.HierarchyScope]::hsPages, [ref]$hierarchy)

    $hierarchy
}

Function Get-OneNotePageContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]
        $OneNoteConnection
    ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PageId
    )

    # Get page's xml content
    [xml]$page = ""
    $OneNoteConnection.GetPageContent($PageId, [ref]$page, 7)

    $page
}

Function Publish-OneNotePage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]
        $OneNoteConnection
    ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PageId
    ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Destination
    ,
        [Parameter(Mandatory)]
        [ValidateSet('pfOneNotePackage', 'pfOneNotePackage', 'pfOneNote ', 'pfPDF', 'pfXPS', 'pfWord', 'pfEMF', 'pfHTML', 'pfOneNote2007')]
        [ValidateNotNullOrEmpty()]
        [string]
        $PublishFormat
    )

    $OneNoteConnection.Publish($PageId, $Destination, $PublishFormat, "")
}