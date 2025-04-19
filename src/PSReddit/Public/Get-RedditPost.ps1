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
    Get-RedditPosts -Subreddit 'powershell' -Sort New -Count 10
.EXAMPLE
    Get-RedditPosts -Subreddit 'powershell' -Sort Top -LastWeek
#>
function Get-RedditPost {
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
    # Determine timeframe (only for Top/Controversial)
    $timeframe = $null
    if ($Sort -in @('Top', 'Controversial')) {
        if ($LastHour) { $timeframe = 'hour' }
        elseif ($LastDay) { $timeframe = 'day' }
        elseif ($LastWeek) { $timeframe = 'week' }
        elseif ($LastMonth) { $timeframe = 'month' }
        elseif ($LastYear) { $timeframe = 'year' }
        elseif ($AllTime) { $timeframe = 'all' }
        else { $timeframe = 'day' } # Default timeframe
    }
    # Authenticate
    $token = Get-RedditOAuthToken
    if (-not $token) {
        Write-Error 'Could not retrieve Reddit OAuth token.'
        return
    }
    $headers = @{ Authorization = "bearer $token"; 'User-Agent' = 'PSReddit/0.1.0 (by u/LukeEvansTech)' }
    $allPosts = @()
    foreach ($sub in $Subreddit) {
        $sortPath = if ($PSBoundParameters.ContainsKey('Sort') -and $Sort) { $Sort.ToLower() } else { 'new' }
        if ([string]::IsNullOrWhiteSpace($sortPath)) { $sortPath = 'new' }
        $uri = "https://oauth.reddit.com/r/$sub/$($sortPath)?limit=$Count"
        if ($DebugApi) {
            Write-Verbose "[DEBUG] Sort param: $Sort"
            Write-Verbose "[DEBUG] sortPath: $sortPath"
            Write-Verbose "[DEBUG] sub: $sub"
            Write-Verbose "[DEBUG] Count: $Count"
            Write-Verbose "[DEBUG] Raw URI string: $uri"
            Write-Verbose "[DEBUG] URI as char array: $($uri.ToCharArray() -join ',')"
        }
        # Only add timeframe for 'top' and 'controversial' sorts
        if ($timeframe -and ($sortPath -eq 'top' -or $sortPath -eq 'controversial')) {
            $uri += "&t=$timeframe"
        }
        $uri += "&api_type=json"
        if ($DebugApi) { Write-Verbose "[DEBUG] Requesting: $uri" }
        try {
            $headers['User-Agent'] = 'PSReddit/0.1.0 (by u/LukeEvansTech on GitHub)'
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction Stop
            if ($response.data.children) {
                $posts = $response.data.children | ForEach-Object { [PSCustomObject]$_.data }
                $allPosts += $posts
            } else {
                Write-Error "No posts found or invalid subreddit: $sub"
            }
        } catch {
            if ($DebugApi) {
                $webResponse = $_.Exception.Response
                try {
                    if ($webResponse -is [System.Net.Http.HttpResponseMessage]) {
                        Write-Verbose "[DEBUG] Status: $($webResponse.StatusCode)"
                        Write-Verbose "[DEBUG] Headers: $($webResponse.Headers | ConvertTo-Json -Compress)"
                        # Try to read the body, but skip if disposed
                        try {
                            $body = $webResponse.Content.ReadAsStringAsync().Result
                            Write-Verbose "[DEBUG] Body: $body"
                        } catch { Write-Verbose "[DEBUG] Body: <disposed or unavailable>" }
                    } elseif ($webResponse) {
                        $reader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
                        $body = $reader.ReadToEnd()
                        Write-Verbose "[DEBUG] Status: $($webResponse.StatusCode)"
                        Write-Verbose "[DEBUG] Headers: $($webResponse.Headers | ConvertTo-Json -Compress)"
                        Write-Verbose "[DEBUG] Body: $body"
                    } else {
                        Write-Verbose "[DEBUG] No web response object available. Exception: $_"
                    }
                } catch { Write-Verbose "[DEBUG] Could not extract debug info from response: $_" }
            }
            Write-Error "Failed to retrieve posts for subreddit '$sub': $($_.Exception.Message)"
        }
    }
    return $allPosts
}