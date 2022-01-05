# SPDX-License-Identifier: GPL-3.0

Function Validate-Dependencies {
    [CmdletBinding()]
    param ()

    # Validate assemblies
    if ( ($env:OS -imatch 'Windows') -and ! (Get-Item -Path $env:windir\assembly\GAC_MSIL\*onenote*) ) {
        "There are missing onenote assemblies. Please ensure the Desktop version of Onenote 2016 or above is installed." | Write-Warning
    }

    # Validate dependencies
    if (! (Get-Command -Name 'pandoc.exe') ) {
        throw "Could not locate pandoc.exe. Please ensure pandoc is installed."
    }
}