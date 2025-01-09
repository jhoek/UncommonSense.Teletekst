function Get-TeletekstTrafficJam
{
    param
    (
    )

    $DutchCulture = Get-Culture 'nl-NL'
    $SubPage = 1
    $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage" -HeaderLine 6 -FooterLine 3 -SkipBlank

    $Content = while ($PageData)
    {
        $DateTimeText = $PageData.Content[4] -replace '\s', '' -replace '^actueel', '' -replace 'uur$', ''
        $DateTime = [DateTime]::ParseExact($DateTimeText, 'ddMMM\.HH\:mm', $DutchCulture)

        $PageData.Payload

        $SubPage++
        $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage" -HeaderLine 6 -FooterLine 3 -SkipBlank
    }

    [PSCustomObject]@{
        Page       = 730
        DateTime   = $DateTime
        Link       = 'https://nos.nl/teletekst#730'
        Title      = 'Verkeersinformatie'
        Content    = NormalizeText($Content -join ' ')
        PSTypeName = 'UncommonSense.Teletekst.Traffic'
    }

}