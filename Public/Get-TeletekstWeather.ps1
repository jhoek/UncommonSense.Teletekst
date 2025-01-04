function Get-TeletekstWeather
{
    param
    (
    )

    $PageData = Invoke-RestMethod -Uri "https://teletekst-data.nos.nl/json/703"
    $Content = $PageData | Select-Object -ExpandProperty Content
    $Document = ConvertTo-HtmlDocument -Text $Content

    $DateTimeText = $Document | Select-HtmlNode -CssSelector '.blue' -All | Select-Object -Skip 1 -First 1 | Get-HtmlNodeText
    $DateTimeText = $DateTimeText -replace '\s', '' -replace '^WEEROVERZICHT', '' -replace 'UUR$', ''
    $DateTimeElements = $DateTimeText -split ':'
    $DateTime = Get-Date -Hour $DateTimeElements[0] -Minute $DateTimeElements[1] -Second 0 -MilliSecond 0
    if ($DateTime -gt (Get-Date)) { $DateTime = $DateTime.AddDay(-1) } # When current time is after midnight, but latest update was before midnight

    [PSCustomObject]@{
        Page       = 703
        DateTime   = $DateTime
        Title      = NormalizeCase(NormalizeTitle(($Document | Select-HtmlNode -CssSelector '.green' -All | Select-Object -Skip 2 -First 1 | Get-HtmlNodeText )))
        Link       = 'https://nos.nl/teletekst#703'
        Content    = NormalizeText(($Document | Select-HtmlNode -CssSelector 'span.cyan' -All | Select-Object -SkipLast 1 | Get-HtmlNodeText) -join ' ')
        PSTypeName = 'UncommonSense.Teletekst.Weather'
    }
}