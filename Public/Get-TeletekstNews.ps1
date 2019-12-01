function NormalizeTitle([string]$Text)
{
    $Text = $Text -replace '\.*\s*$', ''
    $Text = NormalizeText($Text)

    $Text
}

function NormalizeText([string]$Text)
{
    $Text = $Text -replace ',(\S)', ', $1'
    $Text = $Text -replace ':(\S)', ': $1'
    $Text = $Text -replace '\.(\w)', '. $1'

    $Text
}

function GetNewsContent([ValidatePattern('\d{3}')][string]$PageNo)
{
    Invoke-RestMethod -Uri "http://teletekst-data.nos.nl/json/$PageNo" `
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

                [PSCustomObject]@{ 
                    Type       = $CurrentType
                    Title      = NormalizeTitle($Title.Groups[1].Value.Trim())
                    Page       = $PageNo
                    Content    = NormalizeText((GetNewsContent($PageNo)) -join ' ')
                    PSTypeName = 'UncommonSense.Teletekst.NewsStory'                
                } 
            }    
        }
}
}

Get-TeletekstNews -Type Domestic `
| Select-Object -First 1 `
| Select-Object -ExpandProperty Content