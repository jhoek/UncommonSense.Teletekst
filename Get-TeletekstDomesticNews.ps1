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

    Invoke-RestMethod -Uri 'http://teletekst-data.nos.nl/json/103' `
    | Select-Object -ExpandProperty content `
    | ForEach-Object { $_ -split "`n" } `
    | Where-Object { $_ -match '<span class="yellow ">\s*(.*)<a class="yellow" href=".*">(\d+)</a></span>' } `
    | ForEach-Object { [PSCustomObject]@{ Title = NormalizeTitle($Matches[1]); Page = $Matches[2] } }    
}

Get-TeletekstDomesticNews