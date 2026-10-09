BeforeAll {
    $manifest = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', '..', 'PSReddit', 'PSReddit.psd1')
    Get-Module -Name 'PSReddit' -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $manifest -Force
}

Describe 'Get-RedditTimeframe' -Tag Unit {
    It 'returns nothing for the <_> sort' -ForEach 'New', 'Rising', 'Hot' {
        InModuleScope PSReddit -Parameters @{ Sort = $_ } {
            Get-RedditTimeframe -Sort $Sort -BoundParameters @{ LastWeek = [switch]$true } -Default 'day' | Should -BeNullOrEmpty
        }
    }

    It 'returns the default when no switch is set' {
        InModuleScope PSReddit {
            Get-RedditTimeframe -Sort 'Top' -BoundParameters @{} -Default 'all' | Should -BeExactly 'all'
        }
    }

    It 'ignores a switch passed as $false' {
        InModuleScope PSReddit {
            Get-RedditTimeframe -Sort 'Top' -BoundParameters @{ LastHour = [switch]$false } -Default 'day' | Should -BeExactly 'day'
        }
    }

    It 'picks the shortest timeframe when several switches are set' {
        InModuleScope PSReddit {
            $bound = @{ AllTime = [switch]$true; LastWeek = [switch]$true }
            Get-RedditTimeframe -Sort 'Controversial' -BoundParameters $bound -Default 'day' | Should -BeExactly 'week'
        }
    }
}
