function Get-TeletekstTrafficJam
{
    param
    (
    )

    $DutchCulture = Get-Culture 'nl-NL'
    $SubPage = 1
    $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage" -HeaderLine 4 -FooterLine 3

    while ($PageData)
    {
        $DateTimeText = $PageData.Payload[4] -replace '\s', '' -replace '^actueel', '' -replace 'uur$', ''
        $DateTime = [DateTime]::ParseExact($DateTimeText, 'ddMMM\.HH\:mm', $DutchCulture)
        "**$($DateTime)**"

        $PageData.Payload

        $SubPage++
        $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage" -HeaderLine 4 -FooterLine 3
    }
}