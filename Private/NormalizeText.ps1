function NormalizeText([string]$Text)
{
    # Comma followed by non-whitepace, e.g. 'foo,baz'
    $Text = $Text -replace ',([\S])', ', $1'

    # Comma preceded by digit, followed by space and digit, e.g. '2, 2 liters'
    $Text = $Text -replace '(\d),\s(\d)', '$1,$2'

    # (Semi)colon followed by non-whitespace, e.g. 'foo:baz'
    $Text = $Text -replace '([:;])(\S)', '$1 $2'

    # Full stop followed by a letter, e.g. 'foo.baz'
    $Text = $Text -replace '\.([a-zA-Z])', '. $1'

    # Hyphen in compound words, e.g. 'Schengen-landen'
    $Text = $Text -replace '-\s', '-'

    # Times
    $Text = $Text -replace '(\d{0,2})\.\s+(\d{2})\suur', '$1.$2 uur'

    $Text
}