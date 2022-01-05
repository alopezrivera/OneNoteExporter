# SPDX-License-Identifier: GPL-3.0

Function New-OneNoteConnection {
    [CmdletBinding()]
    param ()

    # Create a OneNote connection. See: https://docs.microsoft.com/en-us/office/client-developer/onenote/application-interface-onenote
    if ($PSVersionTable.PSVersion.Major -le 5) {
        if ($OneNote = New-Object -ComObject OneNote.Application) {
            $OneNote
        }else {
            throw "Failed to make connection to OneNote."
        }
    }else {
        # Works between powershell 6.0 and 7.0, but not >= 7.1
        if (Add-Type -Path $env:windir\assembly\GAC_MSIL\Microsoft.Office.Interop.OneNote\15.0.0.0__71e9bce111e9429c\Microsoft.Office.Interop.OneNote.dll -PassThru) {
            $OneNote = [Microsoft.Office.Interop.OneNote.ApplicationClass]::new()
            $OneNote
        }else {
            throw "Failed to make connection to OneNote."
        }
    }
}

Function Remove-OneNoteConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $OneNoteConnection
    )

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($OneNoteConnection) | Out-Null
}
