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

    $Text
}

function Get-TeletekstDomesticNews 
{
    param
    (
    )
    #| Where-Object { $_ -match '<span class="yellow ">\s*(.*)<a class="yellow" href=".*">(\d+)</a></span>' } `

    Invoke-RestMethod -Uri 'http://teletekst-data.nos.nl/json/103' `
    | Select-Object -ExpandProperty content `
    | ForEach-Object { ($_ -split "`n").Trim() } `
    | Where-Object { $_ } `
    | ForEach-Object { 
        $Title = [regex]::Match($_, '^<span class="yellow ">(.*?)<')
        $PageNo = [regex]::Match($_, '(\d{3})</a></span>$')

        if ($Title.Success -and $PageNo.Success)
        {
            [PSCustomObject]@{ Title = NormalizeTitle($Title.Groups[1].Value.Trim()); Page = $PageNo.Groups[1].Value.Trim() } 
        }    
    }
}

Get-TeletekstDomesticNews