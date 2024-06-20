BeforeAll {
    Import-Module "$PSScriptRoot/UncommonSense.Teletekst.psd1"
}

Describe 'UncommonSense.Teletekst' {
    It 'Returns <Type> news' {
        $Result = Get-TeletekstNews -Type $Type
        $Result.Length | Should -BeGreaterThan 3 -Because 'Normally at least 3 stories'

        $Result.Foreach{
            $_.Type | Should -Be $Type
            $_.Page | Should -BeIn $Pages
            $_.Title | Should -Not -BeNullOrEmpty
            $_.Link | Should -Not -BeNullOrEmpty
            $_.Content.Length | Should -BeGreaterThan 100
        }
    } -TestCases @(
        @{Type = 'domestic'; Pages = 104..124 }
        @{Type = 'foreign'; Pages = 125..137 }
    )
}