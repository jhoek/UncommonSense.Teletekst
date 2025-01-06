function Get-TeletekstPage
{
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Uri
    )

    Invoke-WebRequest -Uri $Uri
    | Select-Object -ExpandProperty Content
    | ConvertFrom-Json -Depth 10
    | Select-Object -ExpandProperty Content
    | ForEach-Object { $_ -replace '&#xF020;', '' }
    | ForEach-Object { $_ -replace '&#xF02c;', '' }
    | ForEach-Object { $_ -replace '&#xF02f;', '' }
    | ForEach-Object { [System.Web.HttpUtility]::HtmlDecode($_) }
    | ForEach-Object { $_ -replace '<span.*?>', '' }
    | ForEach-Object { $_ -replace '</span>', '' }
    | ForEach-Object { $_ -replace '<a.*?>', '' }
    | ForEach-Object { $_ -replace '</a>', '' }
}