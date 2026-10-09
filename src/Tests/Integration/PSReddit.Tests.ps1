# Pester tests for PSReddit against the live Reddit API.
# They need REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET; without them the whole block is
# reported as Skipped (decided at discovery, so a missing credential can never show as a pass).
BeforeDiscovery {
    $skipTests = -not ($env:REDDIT_CLIENT_ID -and $env:REDDIT_CLIENT_SECRET)
    if ($skipTests) {
        Write-Warning 'REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET are not set: skipping the integration tests.'
    }
}

Describe 'PSReddit Integration Tests' -Tag Integration -Skip:$skipTests {
    BeforeAll {
        Import-Module ([System.IO.Path]::Combine($PSScriptRoot, '..', '..', 'PSReddit', 'PSReddit.psd1')) -Force
    }

    It 'Should retrieve an OAuth token' {
        $token = Get-RedditOAuthToken
        $token | Should -Not -BeNullOrEmpty
        # Accept JWT format (three dot-separated base64url strings)
        $token | Should -Match '^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$'
    }

    # Last-day listings use r/AskReddit: a smaller subreddit can genuinely go a day without a
    # post (r/powershell's newest post was 25 h old on 2026-10-09, so its Top/day was empty).
    It 'Should retrieve Top posts for the last day' {
        $posts = Get-RedditSubredditPost -Subreddit 'AskReddit' -Sort 'Top' -LastDay -Count 3
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].title | Should -Not -BeNullOrEmpty
        $posts[0].author | Should -Not -BeNullOrEmpty
        $posts[0].subreddit | Should -Be 'AskReddit'
    }

    It 'Should default to Top over the last day when no sort is given' {
        $posts = Get-RedditSubredditPost -Subreddit 'AskReddit' -Count 3
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].subreddit | Should -Be 'AskReddit'
    }

    It 'Should retrieve Top posts for all time' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Top -AllTime -Count 2
        $posts | Should -Not -BeNullOrEmpty
    }

    It 'Should retrieve Controversial posts for last week' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Controversial -LastWeek -Count 2
        $posts | Should -Not -BeNullOrEmpty
    }

    It 'Should retrieve New posts (no timeframe)' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort New -Count 2
        $posts | Should -Not -BeNullOrEmpty
    }

    It 'Should retrieve Rising posts (no timeframe)' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Rising -Count 2
        $posts | Should -Not -BeNullOrEmpty
    }

    It 'Should retrieve Hot posts (no timeframe)' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Hot -Count 2
        $posts | Should -Not -BeNullOrEmpty
    }

    It 'Should retrieve posts from multiple subreddits' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell', 'dotnet' -Sort Top -LastMonth -Count 1
        $posts | Should -Not -BeNullOrEmpty
        $posts.Count | Should -BeGreaterThan 1
    }

    It 'Should handle an invalid subreddit gracefully' {
        # Invoke-Build runs with ErrorActionPreference = Stop, so silence the expected error and assert on it.
        $posts = Get-RedditSubredditPost -Subreddit 'thissubdoesnotexist12345' -Sort Top -LastDay -Count 1 -ErrorAction SilentlyContinue -ErrorVariable err
        $posts | Should -BeNullOrEmpty
        $err.Exception.Message | Should -Contain "Failed to retrieve posts for subreddit 'thissubdoesnotexist12345': Response status code does not indicate success: 404 (Not Found)."
    }

    It 'Should respect the Count parameter' {
        $posts = Get-RedditSubredditPost -Subreddit 'AskReddit' -Sort Top -LastDay -Count 5
        $posts.Count | Should -Be 5
    }

    # Tests for Get-RedditUserPost. They use long-standing accounts with public submissions;
    # u/LukeEvansTech returned an empty listing from CI on 2026-10-09.
    It 'Should retrieve user posts (New sort)' {
        $posts = Get-RedditUserPost -Username 'spez' -Sort New -Count 3
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].author | Should -Be 'spez'
    }

    # Not u/spez here: Reddit returns an empty all-time Top listing for that one account (his
    # Top for the year, and other users' all-time Top, both work; checked 2026-10-09).
    It 'Should retrieve user Top posts' {
        $posts = Get-RedditUserPost -Username 'kn0thing' -Sort Top -AllTime -Count 2
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].author | Should -Be 'kn0thing'
    }

    It 'Should handle multiple usernames' {
        $posts = Get-RedditUserPost -Username 'spez', 'kn0thing' -Sort New -Count 1
        $posts | Should -Not -BeNullOrEmpty
        $posts.Count | Should -BeGreaterThan 1
    }
}