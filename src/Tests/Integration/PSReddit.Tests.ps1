# Pester tests for PSReddit

Describe 'PSReddit Integration Tests' {
    # Adjusted path for the new structure
    Import-Module "$PSScriptRoot/../../PSReddit/PSReddit.psd1" -Force

    BeforeAll {
        $clientId = $env:REDDIT_CLIENT_ID
        $clientSecret = $env:REDDIT_CLIENT_SECRET
        if (-not $clientId -or -not $clientSecret) {
            Write-Warning "REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET must be set for integration tests. Skipping."
            $skipTests = $true
        } else {
            $skipTests = $false
        }
    }

    It 'Should retrieve an OAuth token' -Skip:$skipTests {
        if (-not $skipTests) {
            $token = Get-RedditOAuthToken
            $token | Should -Not -BeNullOrEmpty
            # Accept JWT format (three dot-separated base64url strings)
            $token | Should -Match '^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$'
        }
    }

    It 'Should retrieve Top posts (default timeframe)' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort 'Top' -LastDay -Count 3
            $posts | Should -Not -BeNullOrEmpty
            $posts[0].title | Should -Not -BeNullOrEmpty
            $posts[0].author | Should -Not -BeNullOrEmpty
            $posts[0].subreddit | Should -Be 'powershell'
        }
    }

    It 'Should retrieve Top posts for all time' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Top -AllTime -Count 2
            $posts | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should retrieve Controversial posts for last week' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Controversial -LastWeek -Count 2
            $posts | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should retrieve New posts (no timeframe)' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort New -Count 2
            $posts | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should retrieve Rising posts (no timeframe)' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Rising -Count 2
            $posts | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should retrieve Hot posts (no timeframe)' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Hot -Count 2
            $posts | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should retrieve posts from multiple subreddits' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell', 'dotnet' -Sort Top -LastMonth -Count 1
            $posts | Should -Not -BeNullOrEmpty
            $posts.Count | Should -BeGreaterThan 1
        }
    }

    It 'Should handle an invalid subreddit gracefully' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'thissubdoesnotexist12345' -Sort Top -LastDay -Count 1
            $posts | Should -BeNullOrEmpty
        }
    }

    It 'Should respect the Count parameter' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Top -LastDay -Count 5
            $posts.Count | Should -BeLessOrEqual 5
        }
    }

    # Tests for Get-RedditUserPost
    It 'Should retrieve user posts (New sort)' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditUserPost -Username 'LukeEvansTech' -Sort New -Count 3
            $posts | Should -Not -BeNullOrEmpty
            $posts[0].author | Should -Be 'LukeEvansTech'
        }
    }

    It 'Should retrieve user Top posts' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditUserPost -Username 'LukeEvansTech' -Sort Top -AllTime -Count 2
            $posts | Should -Not -BeNullOrEmpty
            $posts[0].author | Should -Be 'LukeEvansTech'
        }
    }

    It 'Should handle multiple usernames' -Skip:$skipTests {
        if (-not $skipTests) {
            $posts = Get-RedditUserPost -Username 'LukeEvansTech', 'reddit' -Sort Top -LastMonth -Count 1
            $posts | Should -Not -BeNullOrEmpty
            $posts.Count | Should -BeGreaterThan 1
        }
    }
}