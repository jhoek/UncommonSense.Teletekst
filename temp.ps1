104..110 `
| ForEach-Object {
    $Content = Invoke-WebRequest -Uri "https://teletekst-data.nos.nl/webplus?p=$($_)-1" | Select-Object -ExpandProperty Content 
    $Title = ($Content | pup '.doubleHeight text{}' --plain | Join-String -Separator ' ').Trim()
    $Text = ($Content | pup '.cyan text{}' --plain `
        | ForEach-Object { $_ -replace '^\s*', '' } `
        | Select-Object -SkipLast 1 `
        | Join-String -Separator ' ') -replace '\s{2,}', ' ' -replace '\.\s', '.' -replace '\.([A-Z])', '. $1' -replace ',(\S)', ', $1'
    
Write-Host $Title -ForegroundColor Cyan
Write-Host $Text
Write-Host

Send-PushoverNotification `
    -ApplicationToken asxmmq8g95jt4ed1qcrucdvu2iuy67 `
    -Recipient u65ckN1X5uHueh7abnWukQ2owNdhAp `
    -Title $Title `
    -Message $Text
}