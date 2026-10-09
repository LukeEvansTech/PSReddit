<#
.SYNOPSIS
    Retrieves posts from one or more subreddits.
.DESCRIPTION
    Uses Reddit's API and OAuth2 to fetch posts from specified subreddit(s).
    You can specify the sort type (Top, New, Rising, Hot, Controversial).
    Timeframe switches (-LastHour, -LastDay, etc.) only apply to 'Top' and 'Controversial' sorts, per Reddit API rules.
    Only one timeframe or sort can be used per call, as the Reddit API does not support combining them.
    Use -Count to specify how many posts to retrieve (max 100).
.PARAMETER Subreddit
    One or more subreddit names (without /r/).
.PARAMETER Sort
    Sort type: Top, New, Rising, Hot, or Controversial. Default is Top.
.PARAMETER LastHour
    Retrieve posts from the last hour (Top/Controversial only).
.PARAMETER LastDay
    Retrieve posts from the last day (default; Top/Controversial only).
.PARAMETER LastWeek
    Retrieve posts from the last week (Top/Controversial only).
.PARAMETER LastMonth
    Retrieve posts from the last month (Top/Controversial only).
.PARAMETER LastYear
    Retrieve posts from the last year (Top/Controversial only).
.PARAMETER AllTime
    Retrieve posts from all time (Top/Controversial only).
.PARAMETER Count
    Number of posts to retrieve per subreddit (max 100, default 25).
.PARAMETER DebugApi
    If specified, outputs verbose debugging information about the API requests and responses.
.NOTES
    Reddit's API only allows one sort and (if applicable) one timeframe per request. Timeframes only apply to 'Top' and 'Controversial' sorts. Other sorts (New, Rising, Hot) ignore timeframe and always return the latest/rising/hot posts.
.EXAMPLE
    Get-RedditSubredditPost -Subreddit 'powershell' -Sort New -Count 10
.EXAMPLE
    Get-RedditSubredditPost -Subreddit 'powershell' -Sort Top -LastWeek
#>
function Get-RedditSubredditPost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Subreddit,
        [Parameter()]
        [ValidateSet('Top', 'New', 'Rising', 'Hot', 'Controversial')]
        [string]$Sort = 'Top',
        [Parameter()]
        [switch]$LastHour,
        [Parameter()]
        [switch]$LastDay,
        [Parameter()]
        [switch]$LastWeek,
        [Parameter()]
        [switch]$LastMonth,
        [Parameter()]
        [switch]$LastYear,
        [Parameter()]
        [switch]$AllTime,
        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Count = 25,
        [Parameter()]
        [switch]$DebugApi
    )

    $timeframe = Get-RedditTimeframe -Sort $Sort -BoundParameters $PSBoundParameters -Default 'day'

    $token = Get-RedditOAuthToken
    if (-not $token) {
        Write-Error 'Could not retrieve Reddit OAuth token.'
        return
    }

    $sortPath = $Sort.ToLowerInvariant()
    foreach ($sub in $Subreddit) {
        $query = [ordered]@{ limit = $Count }
        if ($timeframe) { $query['t'] = $timeframe }
        $query['api_type'] = 'json'

        Invoke-RedditListing -Path "r/$sub/$sortPath" -Query $query -Token $token `
            -Kind 'subreddit' -Name $sub -DebugApi:$DebugApi
    }
}
