function Get-TeletekstTrafficJam
{
    param
    (
    )

    $DutchCulture = Get-Culture 'nl-NL'
    $SubPage = 1
    $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage"

    $PageData = $PageData -split "`n"

    while($PageData)
    {
        $pageData[4]
        $DateTimeText = $PageData[4] -replace '\s', '' -replace '^actueel', '' -replace 'uur$', ''
        $DateTime = [DateTime]::ParseExact($DateTimeText, 'ddMMM\.HH\:mm', $DutchCulture)
        "**$($DateTime)**"
        # $Document

        $SubPage++
        $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/730-$SubPage"
    }
}