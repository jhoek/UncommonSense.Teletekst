function NormalizeTitle([string]$Text)
{
    # Remove leading whitespace
    $Text = $Text -replace '^\s*', ''

    # Remove trailing whitespace
    $Text = $Text -replace '\s*$',''

    # Normalize remaining text
    $Text = NormalizeText($Text)

    $Text
}

function NormalizeText([string]$Text)
{
    # Comma followed by non-whitepace, e.g. 'foo,baz'
    $Text = $Text -replace ',([\S])', ', $1'

    # Comma preceded by digit, followed by space and digit, e.g. '2, 2 liters'
    $Text = $Text -replace '(\d),\s(\d)', '$1,$2'

    # (Semi)colon followed by non-whitespace, e.g. 'foo:baz'
    $Text = $Text -replace '([:;])(\S)', '$1 $2'

    # Full stop followed by a letter, e.g. 'foo.baz'
    $Text = $Text -replace '\.([a-zA-Z])', '. $1'

    # Hyphen in compound words, e.g. 'Schengen-landen'
    $Text = $Text -replace '-\s', '-'

    # Times
    $Text = $Text -replace '(\d{0,2})\.\s+(\d{2})\suur', '$1.$2 uur'

    $Text
}

function GetTitle([string]$Content)
{
    $Content | pup '.doubleHeight text{}' --plain
}

function GetNewsContent([string]$Content)
{
    $Content `
    | ForEach-Object { ($_ -split "`n").Trim() } `
    | Where-Object { $_ } `
    | ForEach-Object { $_ -replace '<a [^>]*?>', '' -replace '</a>', '' } `
    | Select-Object -SkipLast 1 `
    | ForEach-Object { ($_ | pup 'span.cyan text{}' --plain) } `
    | ForEach-Object { $_.Trim() }
}

function Get-TeletekstNews
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Domestic', 'Foreign')]
        [string[]]$Type
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
            $PageData = Invoke-RestMethod -Uri "http://teletekst-data.nos.nl/json/$CurrentPage"

            [PSCustomObject]@{
                Type       = $CurrentType
                Page       = $CurrentPage
                DateTime   = Get-Date
                Title      = NormalizeTitle(GetTitle($PageData.Content))
                Link       = "https://nos.nl/teletekst#$($CurrentPage)"
                Content    = NormalizeText(GetNewsContent($PageData.Content) -join ' ')
                PSTypeName = 'UncommonSense.Teletekst.NewsStory'
            }

            $CurrentPage = $PageData.NextPage
        }
    }
}