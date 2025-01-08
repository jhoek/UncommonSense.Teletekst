function NormalizeCase([string]$Text)
{
    $Text = [regex]::Replace($Text.ToLowerInvariant(), '^(\w)', { param($Match) $Match.Groups[1].Value.ToUpperInvariant() })

    $Text = $Text -replace 'limburg', 'Limburg'

    $Text
    # FIXME: rest
}