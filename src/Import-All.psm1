# SPDX-License-Identifier: GPL-3.0

# Dependency check
Import-Module -DisableNameChecking .\src\Utils\Dependencies.psm1

# Configuration methods
Import-Module -DisableNameChecking .\src\Configuration\Config-Default.psm1
Import-Module -DisableNameChecking .\src\Configuration\Config-Compile.psm1
Import-Module -DisableNameChecking .\src\Configuration\Config-IO.psm1

# Filename methods
Import-Module -DisableNameChecking .\src\Utils\Filename.psm1

# OneNote methods
Import-Module -DisableNameChecking .\src\OneNote\OneNote-Connect.psm1
Import-Module -DisableNameChecking .\src\OneNote\OneNote-Retrieve.psm1

# Conversion methods
Import-Module -DisableNameChecking .\src\Conversion\Conversion-Config.psm1
Import-Module -DisableNameChecking .\src\Conversion\Conversion-Page.psm1
Import-Module -DisableNameChecking .\src\Conversion\Conversion-Log.psm1

# Markup Pack methods
Import-Module -DisableNameChecking .\src\Conversion\Conversion-Markup.psm1