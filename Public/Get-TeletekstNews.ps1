function NormalizeTitle([string]$Text)
{
    $Text = $Text -replace '\.*\s*$', ''
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

    # Times
    $Text = $Text -replace '(\d{0,2})\.\s+(\d{2})\suur', '$1.$2 uur'

    $Text
}

function GetNewsContent([string]$PageUrl)
{
    Invoke-RestMethod -Uri $PageUrl `
    | Select-Object -ExpandProperty Content `
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

        $IndexPageNo = switch ($CurrentType)
        {
            'Domestic' { 102 }
            'Foreign' { 103 }
        }

        Invoke-RestMethod -Uri "http://teletekst-data.nos.nl/json/$IndexPageNo" `
        | Select-Object -ExpandProperty content `
        | ForEach-Object { ($_ -split "`n").Trim() } `
        | Where-Object { $_ } `
        | ForEach-Object { $_ -replace '<a [^>]*?>', '' -replace '</a>', '' } `
        | ForEach-Object { $_ -replace '</span><span class="yellow\s*">', '' } `
        | ForEach-Object { $_ | pup 'span.yellow text{}' --plain } `
        | Select-String -Pattern '^(?<Title>.*)\.*\s(?<PageNo>\d{3})$' `
        | Select-Object -ExpandProperty Matches `
        | ForEach-Object {
            $PageNo = $_.Groups[2].Value.Trim()
            $PageUrl = "http://teletekst-data.nos.nl/json/$PageNo"


            [PSCustomObject]@{
                Type       = $CurrentType
                DateTime   = Get-Date
                Title      = NormalizeTitle($_.Groups[1].Value.Trim())
                Page       = $PageNo
                Link       = "https://nos.nl/teletekst#$($PageNo)"
                Content    = NormalizeText((GetNewsContent($PageUrl)) -join ' ')
                PSTypeName = 'UncommonSense.Teletekst.NewsStory'
            }
        }
}
}