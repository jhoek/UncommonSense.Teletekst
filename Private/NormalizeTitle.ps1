function NormalizeTitle([string]$Text)
{
    # Remove leading whitespace
    $Text = $Text -replace '^\s*', ''

    # Remove trailing whitespace
    $Text = $Text -replace '\s*$', ''

    # Normalize remaining text
    $Text = NormalizeText($Text)

    $Text
}
