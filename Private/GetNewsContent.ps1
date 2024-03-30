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