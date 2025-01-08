function Get-TeletekstPageContent
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

    Get-TeletekstPage -Uri $Uri
    | Select-Object -Skip $HeaderLine -SkipLast $FooterLine
}