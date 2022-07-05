Function Write-StringRaw {

    # Write string with special characters.

    # From mkelement0's answer on StackOverflow
    # https://stackoverflow.com/questions/27233342/get-content-and-show-control-characters-such-as-r-visualize-control-character

    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $String
        ,
        [switch] $CaretNotation
    )

    begin {
        # \p{C} matches any Unicode control character, both inside and outside
        # the ASCII range; note that tabs (`t) are control character too, but not spaces.
        $re = [regex] '\p{C}'
    }

    process {

        $re.Replace($String, {
        param($match)
        $handled = $False
        if (-not $CaretNotation) {
            # Translate control chars. that have native PS escape sequences into them.
            $handled = $True
            switch ([Int16] [char] $match.Value) {
            0  { '`0'; break }
            7  { '`a'; break }
            8  { '`b'; break }
            12 { '`f'; break }
            10 { '`n'; break }
            13 { '`r'; break }
            9  { '`t'; break }
            11 { '`v'; break }
            default { $handled = $false }
            } # switch
        }
        if (-not $handled) {
            switch ([Int16] [char] $match.Value) {
                10 { '$'; break } # cat -A / cat -e visualizes LFs as '$'
                # If it's a control character in the ASCII range, 
                # use caret notation too (C0 range).
                # See https://en.wikipedia.org/wiki/Caret_notation
                { $_ -ge 0 -and $_ -le 31 -or $_ -eq 127 } {
                # Caret notation is based on the letter obtained by adding the
                # control-character code point to the code point of '@' (64).
                '^' + [char] (64 + $_)
                break
                }
                # NON-ASCII control characters; use the - PS Core-only - Unicode
                # escape-sequence notation:
                default { '`u{{{0}}}' -f ([int16] [char] $_).ToString('x') }
            }
        } # if (-not $handled)
        })  # .Replace
    } # process

}