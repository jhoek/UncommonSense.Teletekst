function Get-TeletekstTrafficJam
{
    param
    (
    )

    $DutchCulture = Get-Culture 'nl-NL'
    $SubPage = 1
    $PageData = Get-TeletekstPageContent -Uri "https://teletekst-data.nos.nl/json/730-$SubPage"

    $PageData

    while ($PageData)
    {
        $DateTimeText = $PageData[4] -replace '\s', '' -replace '^actueel', '' -replace 'uur$', ''
        $DateTime = [DateTime]::ParseExact($DateTimeText, 'ddMMM\.HH\:mm', $DutchCulture)
        "**$($DateTime)**"

        $SubPage++
        $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage"
    }
}