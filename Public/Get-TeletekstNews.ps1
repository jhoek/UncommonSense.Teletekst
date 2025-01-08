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
            $PageData = Get-TeletekstPage -Uri "https://teletekst-data.nos.nl/json/$CurrentPage" -HeaderLine 4 -FooterLine 3

            [PSCustomObject]@{
                Type       = $CurrentType
                Page       = $CurrentPage
                DateTime   = Get-Date
                Title      = $PageData.Content[2].Trim()
                Link       = "https://nos.nl/teletekst#$($CurrentPage)"
                Content    = NormalizeText($PageData.Payload -join ' ')
                PSTypeName = 'UncommonSense.Teletekst.NewsStory'
            }

            $CurrentPage = $PageData.NextPage
        }
    }
}