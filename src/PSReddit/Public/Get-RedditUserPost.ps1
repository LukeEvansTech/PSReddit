<#
.SYNOPSIS
    Retrieves posts submitted by specific Reddit users.
.DESCRIPTION
    Uses Reddit's API and OAuth2 to fetch posts made by specified Reddit user(s).
    You can specify the sort type (Top, New, Hot, Controversial) and limit the number of posts.
    Timeframe switches (-LastHour, -LastDay, etc.) apply to 'Top' and 'Controversial' sorts, per Reddit API rules.
.PARAMETER Username
    One or more Reddit usernames (without u/).
.PARAMETER Sort
    Sort type: Top, New, Hot, or Controversial. Default is New.
.PARAMETER LastHour
    Retrieve posts from the last hour (Top/Controversial only).
.PARAMETER LastDay
    Retrieve posts from the last day (Top/Controversial only).
.PARAMETER LastWeek
    Retrieve posts from the last week (Top/Controversial only).
.PARAMETER LastMonth
    Retrieve posts from the last month (Top/Controversial only).
.PARAMETER LastYear
    Retrieve posts from the last year (Top/Controversial only).
.PARAMETER AllTime
    Retrieve posts from all time (default; Top/Controversial only).
.PARAMETER Count
    Number of posts to retrieve per user (max 100, default 25).
.PARAMETER DebugApi
    If specified, outputs verbose debugging information about the API requests and responses.
.NOTES
    Reddit's API only allows one sort and (if applicable) one timeframe per request.
    Timeframes only apply to 'Top' and 'Controversial' sorts.
.EXAMPLE
    Get-RedditUserPost -Username 'LukeEvansTech' -Sort New -Count 10
.EXAMPLE
    Get-RedditUserPost -Username 'LukeEvansTech' -Sort Top -LastWeek
#>
function Get-RedditUserPost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Username,
        [Parameter()]
        [ValidateSet('Top', 'New', 'Hot', 'Controversial')]
        [string]$Sort = 'New',
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

    $timeframe = Get-RedditTimeframe -Sort $Sort -BoundParameters $PSBoundParameters -Default 'all'

    $token = Get-RedditOAuthToken
    if (-not $token) {
        Write-Error 'Could not retrieve Reddit OAuth token.'
        return
    }

    $sortPath = $Sort.ToLowerInvariant()
    foreach ($user in $Username) {
        $query = [ordered]@{ limit = $Count; sort = $sortPath }
        if ($timeframe) { $query['t'] = $timeframe }
        $query['api_type'] = 'json'

        Invoke-RedditListing -Path "user/$user/submitted" -Query $query -Token $token `
            -Kind 'user' -Name $user -DebugApi:$DebugApi
    }
}
