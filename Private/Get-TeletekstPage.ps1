function Get-TeletekstPage
{
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Uri,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$HeaderLine = 0,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FooterLine = 0
    )

    $Response = Invoke-RestMethod -Uri $Uri -SkipHttpErrorCheck -StatusCodeVariable StatusCode

    if ($StatusCode -eq 200){
        $Content = $Response
        | Select-Object -ExpandProperty Content
        | ForEach-Object { $_ -replace '&#xF020;', '' }
        | ForEach-Object { $_ -replace '&#xF02c;', '' }
        | ForEach-Object { $_ -replace '&#xF02f;', '' }
        | ForEach-Object { [System.Web.HttpUtility]::HtmlDecode($_) }
        | ForEach-Object { $_ -replace '<span.*?>', '' }
        | ForEach-Object { $_ -replace '</span>', '' }
        | ForEach-Object { $_ -replace '<a.*?>', '' }
        | ForEach-Object { $_ -replace '</a>', '' }
        | ForEach-Object { $_ -split "`n"}

        $Payload = $Content | Select-Object -Skip $HeaderLine -SkipLast $FooterLine

        [PSCustomObject]@{
            Content = $Content
            Payload = $Payload
            PrevPage = $Response.PrevPage
            NextPage = $Response.NextPage
        }
    }
}