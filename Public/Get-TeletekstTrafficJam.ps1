function Get-TeletekstTrafficJam
{
    param
    (
    )

    $DutchCulture = Get-Culture 'nl-NL'
    $SubPage = 1
    $PageData = Invoke-RestMethod -Uri "https://teletekst-data.nos.nl/json/730-$SubPage" -SkipHttpErrorCheck -StatusCodeVariable StatusCode
    $StatusCode

    while($StatusCode -eq '200')
    {
        $Content = $PageData | Select-Object -ExpandProperty Content
        $Document = ConvertTo-HtmlDocument -Text $Content

        $DateTimeText = $Document | Select-HtmlNode -CssSelector '.cyan.bg-blue' -All | Select-Object -Skip 1 -First 1 | Get-HtmlNodeText
        $DateTimeText = $DateTimeText -replace '\s', '' -replace '^actueel', '' -replace 'uur$', ''
        $DateTime = [DateTime]::ParseExact($DateTimeText, 'ddMMM\.HH\:mm', $DutchCulture)
        "**$($DateTime)**"
        # $Document

        $SubPage++
        $PageData = Invoke-RestMethod -Uri "https://teletekst-data.nos.nl/json/730-$SubPage" -SkipHttpErrorCheck -StatusCodeVariable StatusCode
        $StatusCode
    }
}