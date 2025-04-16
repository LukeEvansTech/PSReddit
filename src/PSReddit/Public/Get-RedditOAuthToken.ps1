<#
.SYNOPSIS
    Retrieves an OAuth2 bearer token from Reddit.
.DESCRIPTION
    Authenticates with Reddit using client credentials from environment variables (REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET).
.EXAMPLE
    $token = Get-RedditOAuthToken
.NOTES
    Requires environment variables REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET to be set.
#>
function Get-RedditOAuthToken {
    [CmdletBinding()]
    param ()
    $clientId = $env:REDDIT_CLIENT_ID
    $clientSecret = $env:REDDIT_CLIENT_SECRET
    if (-not $clientId -or -not $clientSecret) {
        Write-Error 'REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET environment variables must be set.'
        return
    }
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${clientId}:${clientSecret}"))
    $headers = @{ Authorization = "Basic $auth" }
    $body = @{ grant_type = 'client_credentials' }
    try {
        $response = Invoke-RestMethod -Uri 'https://www.reddit.com/api/v1/access_token' -Method Post -Headers $headers -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
        if ($response.access_token) {
            return $response.access_token
        } else {
            Write-Error 'Failed to retrieve access token from Reddit.'
        }
    } catch {
        Write-Error "OAuth token request failed: $_"
    }
}