function Get-TeletekstTrafficJam
{
    param
    (
    )

    $DutchCulture = Get-Culture 'nl-NL'
    $SubPage = 1
    $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage"

    while ($PageData)
    {
        $DateTimeText = $PageData.Content[4] -replace '\s', '' -replace '^actueel', '' -replace 'uur$', ''
        $DateTime = [DateTime]::ParseExact($DateTimeText, 'ddMMM\.HH\:mm', $DutchCulture)
        "**$($DateTime)**"

        $SubPage++
        $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage"
    }
}