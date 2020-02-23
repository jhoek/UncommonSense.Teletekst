$Text = Invoke-WebRequest -Uri 'https://teletekst-data.nos.nl/webplus?p=121-1' `
| Select-Object -ExpandProperty Content `
| pup '.cyan text{}' --plain `
| ForEach-Object { $_ -replace '^\s*', '' } `
| Select-Object -SkipLast 1 `
| Join-String -Separator ' '

$Text -replace '\s{2,}', ' ' -replace '\.\s', '.' -replace '\.([A-Z])', '. $1' -replace ',(\S)', ', $1'