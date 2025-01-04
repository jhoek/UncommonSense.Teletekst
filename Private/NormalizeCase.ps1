function NormalizeCase([string]$Text)
{
    [regex]::Replace($Text.ToLowerInvariant(), '^(\w)', { param($Match) $Match.Groups[1].Value.ToUpperInvariant() })
}