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

    # Colon followed by non-whitespace, e.g. 'foo:baz'
    $Text = $Text -replace ':(\S)', ': $1'

    # Full stop followed by word character, e.g. 'foo.baz'
    $Text = $Text -replace '\.(\w)', '. $1'

    $Text
}

function GetNewsContent([string]$PageUrl)
{
    Invoke-RestMethod -Uri $PageUrl `
    | Select-Object -ExpandProperty Content `
    | ForEach-Object { ($_ -split "`n").Trim() } `
    | Where-Object { $_ } `
    | ForEach-Object {
        $Line = [regex]::Match($_, '<span class="cyan ">(.*?)<')

        if ($Line.Success)
        {
            $Line.Groups[1].Value.Trim()
        }
    }
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
        | ForEach-Object { 
            $Title = [regex]::Match($_, '^<span class="yellow ">(.*?)<')
            $PageNo = [regex]::Match($_, '(\d{3})</a></span>$')

            if ($Title.Success -and $PageNo.Success)
            {
                $PageNo = $PageNo.Groups[1].Value.Trim() 
                $PageUrl = "http://teletekst-data.nos.nl/json/$PageNo"

                [PSCustomObject]@{ 
                    Type       = $CurrentType
                    DateTime   = Get-Date
                    Title      = NormalizeTitle($Title.Groups[1].Value.Trim())
                    Page       = $PageNo
                    Link       = $PageUrl
                    Content    = NormalizeText((GetNewsContent($PageUrl)) -join ' ')
                    PSTypeName = 'UncommonSense.Teletekst.NewsStory'                
                } 
            }    
        }
}
}

Get-TeletekstNews -Type Domestic 