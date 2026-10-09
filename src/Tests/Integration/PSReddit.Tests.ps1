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

    It 'Should retrieve Top posts (default timeframe)' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort 'Top' -LastDay -Count 3
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].title | Should -Not -BeNullOrEmpty
        $posts[0].author | Should -Not -BeNullOrEmpty
        $posts[0].subreddit | Should -Be 'powershell'
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
        $posts = Get-RedditSubredditPost -Subreddit 'thissubdoesnotexist12345' -Sort Top -LastDay -Count 1
        $posts | Should -BeNullOrEmpty
    }

    It 'Should respect the Count parameter' {
        $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Top -LastDay -Count 5
        $posts.Count | Should -BeLessOrEqual 5
    }

    # Tests for Get-RedditUserPost
    It 'Should retrieve user posts (New sort)' {
        $posts = Get-RedditUserPost -Username 'LukeEvansTech' -Sort New -Count 3
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].author | Should -Be 'LukeEvansTech'
    }

    It 'Should retrieve user Top posts' {
        $posts = Get-RedditUserPost -Username 'LukeEvansTech' -Sort Top -AllTime -Count 2
        $posts | Should -Not -BeNullOrEmpty
        $posts[0].author | Should -Be 'LukeEvansTech'
    }

    It 'Should handle multiple usernames' {
        $posts = Get-RedditUserPost -Username 'LukeEvansTech', 'reddit' -Sort Top -LastMonth -Count 1
        $posts | Should -Not -BeNullOrEmpty
        $posts.Count | Should -BeGreaterThan 1
    }
}