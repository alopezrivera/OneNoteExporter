# SPDX-License-Identifier: GPL-3.0

Function Print-ConversionErrors {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorCollection
    )

    if ($ErrorCollection.Count -gt 0) {
        "Conversion errors: " | Write-Host
        $ErrorCollection | Where-Object { (Get-Member -InputObject $_ -Name 'CategoryInfo') -and ($_.CategoryInfo.Reason -match 'WriteErrorException') } | Write-Host -ForegroundColor Red
    }
}