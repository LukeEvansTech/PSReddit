BeforeAll {
    $manifest = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', '..', 'PSReddit', 'PSReddit.psd1')
    Get-Module -Name 'PSReddit' -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $manifest -Force

    # A Reddit listing response holding one post per title.
    function ConvertTo-RedditListing {
        param ([string[]]$Title)
        [pscustomobject]@{
            data = [pscustomobject]@{
                children = @(foreach ($t in $Title) { @{ data = @{ title = $t } } })
            }
        }
    }
}

Describe 'Get-RedditUserPost' -Tag Unit {
    BeforeEach {
        Mock Get-RedditOAuthToken -ModuleName PSReddit { 'tok-abc' }
        Mock Invoke-RestMethod -ModuleName PSReddit { ConvertTo-RedditListing -Title 'one', 'two' }
    }

    Context 'Request URI' {
        It 'defaults to the New sort with no timeframe' {
            $null = Get-RedditUserPost -Username 'someone'

            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'https://oauth.reddit.com/user/someone/submitted?limit=25&sort=new&api_type=json'
            }
        }

        It 'defaults the timeframe to all time on the <_> sort' -ForEach 'Top', 'Controversial' {
            $null = Get-RedditUserPost -Username 'someone' -Sort $_

            $expectedUri = "https://oauth.reddit.com/user/someone/submitted?limit=25&sort=$($_.ToLower())&t=all&api_type=json"
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -eq $expectedUri }
        }

        It 'sends t=<Expected> for -<Switch>' -ForEach @(
            @{ Switch = 'LastHour'; Expected = 'hour' }
            @{ Switch = 'LastDay'; Expected = 'day' }
            @{ Switch = 'LastWeek'; Expected = 'week' }
            @{ Switch = 'LastMonth'; Expected = 'month' }
            @{ Switch = 'LastYear'; Expected = 'year' }
        ) {
            $splat = @{ Username = 'someone'; Sort = 'Top'; $Switch = $true }
            $null = Get-RedditUserPost @splat

            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -like "*&t=$Expected&*" }
        }

        It 'sends no timeframe on the Hot sort' {
            $null = Get-RedditUserPost -Username 'someone' -Sort Hot -LastWeek

            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'https://oauth.reddit.com/user/someone/submitted?limit=25&sort=hot&api_type=json'
            }
        }
    }

    Context 'Results and errors' {
        It 'queries each user once and returns all posts' {
            $posts = Get-RedditUserPost -Username 'alice', 'bob'

            $posts.Count | Should -Be 4
            Should -Invoke Get-RedditOAuthToken -ModuleName PSReddit -Times 1 -Exactly
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 2 -Exactly
        }

        It 'stops before calling Reddit when no token is returned' {
            Mock Get-RedditOAuthToken -ModuleName PSReddit { $null }

            $posts = Get-RedditUserPost -Username 'someone' -ErrorVariable err -ErrorAction SilentlyContinue

            $posts | Should -BeNullOrEmpty
            $err[0].Exception.Message | Should -Be 'Could not retrieve Reddit OAuth token.'
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 0 -Exactly
        }

        It 'reports an empty listing as an error' {
            Mock Invoke-RestMethod -ModuleName PSReddit { ConvertTo-RedditListing -Title @() }

            $null = Get-RedditUserPost -Username 'nobody' -ErrorVariable err -ErrorAction SilentlyContinue

            $err[0].Exception.Message | Should -Be 'No posts found or invalid user: nobody'
        }

        It 'reports a failed request and carries on with the next user' {
            Mock Invoke-RestMethod -ModuleName PSReddit -ParameterFilter { $Uri -like '*/user/gone/*' } { throw 'HTTP 404' }

            $posts = Get-RedditUserPost -Username 'gone', 'someone' -ErrorVariable err -ErrorAction SilentlyContinue

            $posts.Count | Should -Be 2
            $err.Exception.Message | Should -Contain "Failed to retrieve posts for user 'gone': HTTP 404"
        }
    }
}
