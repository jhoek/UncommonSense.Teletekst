function Get-TeletekstNews
{
    param
    (
        [Parameter()]
        [ValidateSet('Domestic', 'Foreign')]
        [ValidateCount(1, [int]::MaxValue)]
        [string[]]$Type = @('Domestic', 'Foreign')
    )

    $Type.ForEach{
        $CurrentType = $_

        $PageRange = switch ($CurrentType)
        {
            'Domestic' { 104..124 }
            'Foreign' { 125..137 }
        }

        $CurrentPage = $PageRange[0]

        while ($CurrentPage -in $PageRange)
        {
            $PageData = Invoke-RestMethod -Uri "https://teletekst-data.nos.nl/json/$CurrentPage"
            $Content = $PageData | Select-Object -ExpandProperty Content
            $Document = ConvertTo-HtmlDocument -Text $Content

            [PSCustomObject]@{
                Type       = $CurrentType
                Page       = $CurrentPage
                DateTime   = Get-Date
                Title      = NormalizeTitle(($Document | Select-HtmlNode -CssSelector '.bg-blue' -All | Get-HtmlNodeText))
                Link       = "https://nos.nl/teletekst#$($CurrentPage)"
                Content    = NormalizeText(($Document | Select-HtmlNode -CssSelector 'span.cyan' -All | Select-Object -SkipLast 1 | Get-HtmlNodeText) -join ' ')
                PSTypeName = 'UncommonSense.Teletekst.NewsStory'
            }

            $CurrentPage = $PageData.NextPage
        }
    }
}