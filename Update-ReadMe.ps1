Get-Module UncommonSense.Teletekst -ListAvailable | Import-Module -Force

Get-Command -Module UncommonSense.Teletekst |
    Sort-Object Noun, Verb |
    Convert-HelpToMarkDown `
        -Title 'UncommonSense.Teletekst' `
        -Description 'PowerShell module for retrieving NOS (Dutch) Teletekst news.' |
    Out-File .\README.md -Encoding utf8