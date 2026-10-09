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

Describe 'Get-RedditSubredditPost' -Tag Unit {
    BeforeEach {
        Mock Get-RedditOAuthToken -ModuleName PSReddit { 'tok-abc' }
        Mock Invoke-RestMethod -ModuleName PSReddit { ConvertTo-RedditListing -Title 'one', 'two' }
    }

    Context 'Request URI' {
        It 'defaults to the Top sort over the last day, as documented' {
            $null = Get-RedditSubredditPost -Subreddit 'powershell'

            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'https://oauth.reddit.com/r/powershell/top?limit=25&t=day&api_type=json'
            }
        }

        It 'sends t=<Expected> for -<Switch> on the <Sort> sort' -ForEach @(
            @{ Sort = 'Top'; Switch = 'LastHour'; Expected = 'hour' }
            @{ Sort = 'Top'; Switch = 'LastWeek'; Expected = 'week' }
            @{ Sort = 'Top'; Switch = 'LastMonth'; Expected = 'month' }
            @{ Sort = 'Top'; Switch = 'LastYear'; Expected = 'year' }
            @{ Sort = 'Top'; Switch = 'AllTime'; Expected = 'all' }
            @{ Sort = 'Controversial'; Switch = 'LastDay'; Expected = 'day' }
        ) {
            $splat = @{ Subreddit = 'powershell'; Sort = $Sort; $Switch = $true }
            $null = Get-RedditSubredditPost @splat

            $expectedUri = "https://oauth.reddit.com/r/powershell/$($Sort.ToLower())?limit=25&t=$Expected&api_type=json"
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -eq $expectedUri }
        }

        It 'sends no timeframe on the <_> sort, even when a timeframe switch is given' -ForEach 'New', 'Rising', 'Hot' {
            $null = Get-RedditSubredditPost -Subreddit 'powershell' -Sort $_ -LastWeek

            $expectedUri = "https://oauth.reddit.com/r/powershell/$($_.ToLower())?limit=25&api_type=json"
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -eq $expectedUri }
        }

        It 'passes -Count through as the limit' {
            $null = Get-RedditSubredditPost -Subreddit 'powershell' -Sort New -Count 7

            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -like '*limit=7&*' }
        }

        It 'sends the bearer token and a versioned User-Agent' {
            $version = (Get-Module -Name PSReddit).Version
            $null = Get-RedditSubredditPost -Subreddit 'powershell'

            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter {
                $Headers.Authorization -eq 'bearer tok-abc' -and
                $Headers['User-Agent'] -eq "PSReddit/$version (by u/LukeEvansTech on GitHub)"
            }
        }
    }

    Context 'Results' {
        It 'returns each post as an object with the Reddit fields' {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell'

            $posts.Count | Should -Be 2
            $posts[0] | Should -BeOfType [pscustomobject]
            $posts.title | Should -Be @('one', 'two')
        }

        It 'queries each subreddit once, fetches one token, and returns all posts' {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell', 'dotnet'

            $posts.Count | Should -Be 4
            Should -Invoke Get-RedditOAuthToken -ModuleName PSReddit -Times 1 -Exactly
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -like '*/r/powershell/*' }
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter { $Uri -like '*/r/dotnet/*' }
        }
    }

    Context 'Errors' {
        It 'stops before calling Reddit when no token is returned' {
            Mock Get-RedditOAuthToken -ModuleName PSReddit { $null }

            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -ErrorVariable err -ErrorAction SilentlyContinue

            $posts | Should -BeNullOrEmpty
            $err[0].Exception.Message | Should -Be 'Could not retrieve Reddit OAuth token.'
            Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 0 -Exactly
        }

        It 'reports an empty listing as an error' {
            Mock Invoke-RestMethod -ModuleName PSReddit { ConvertTo-RedditListing -Title @() }

            $posts = Get-RedditSubredditPost -Subreddit 'nosuchsub' -ErrorVariable err -ErrorAction SilentlyContinue

            $posts | Should -BeNullOrEmpty
            $err[0].Exception.Message | Should -Be 'No posts found or invalid subreddit: nosuchsub'
        }

        It 'reports a failed request and carries on with the next subreddit' {
            Mock Invoke-RestMethod -ModuleName PSReddit -ParameterFilter { $Uri -like '*/r/broken/*' } { throw 'HTTP 503' }

            $posts = Get-RedditSubredditPost -Subreddit 'broken', 'powershell' -ErrorVariable err -ErrorAction SilentlyContinue

            $posts.Count | Should -Be 2
            $err.Exception.Message | Should -Contain "Failed to retrieve posts for subreddit 'broken': HTTP 503"
        }

        It 'rejects a -Count of <_>' -ForEach 0, 101 {
            { Get-RedditSubredditPost -Subreddit 'powershell' -Count $_ } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-RedditSubredditPost'
        }

        It 'rejects an unknown -Sort' {
            { Get-RedditSubredditPost -Subreddit 'powershell' -Sort 'Best' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-RedditSubredditPost'
        }
    }

    Context '-DebugApi' {
        It 'writes the request URI to the verbose stream' {
            $verbose = Get-RedditSubredditPost -Subreddit 'powershell' -DebugApi -Verbose 4>&1 |
                Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }

            $verbose.Message | Should -Contain '[DEBUG] Requesting: https://oauth.reddit.com/r/powershell/top?limit=25&t=day&api_type=json'
        }

        It 'says so when the request never reached Reddit' {
            Mock Invoke-RestMethod -ModuleName PSReddit { throw 'name resolution failed' }

            $verbose = Get-RedditSubredditPost -Subreddit 'powershell' -DebugApi -Verbose -ErrorAction SilentlyContinue 4>&1 |
                Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }

            $verbose.Message | Should -Contain '[DEBUG] No HTTP response (the request did not reach Reddit).'
        }
    }
}
