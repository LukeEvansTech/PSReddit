<#
.SYNOPSIS
    Calls one Reddit listing endpoint and emits each post as a PSCustomObject.
.DESCRIPTION
    Shared by the public Get-Reddit*Post commands: builds the oauth.reddit.com URI, sends the
    bearer token and the module's User-Agent, and turns a failed request or an empty listing
    into a non-terminating error so a multi-target call carries on with the next target.
#>
function Invoke-RedditListing {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        # Path below https://oauth.reddit.com/, e.g. 'r/powershell/top'.
        [Parameter(Mandatory)]
        [string]$Path,

        # Query parameters, in the order they should appear in the URI.
        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary]$Query,

        [Parameter(Mandatory)]
        [string]$Token,

        # What is being listed, for error messages: 'subreddit' or 'user'.
        [Parameter(Mandatory)]
        [string]$Kind,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [switch]$DebugApi
    )

    $queryString = @(
        foreach ($key in $Query.Keys) {
            '{0}={1}' -f $key, [uri]::EscapeDataString([string]$Query[$key])
        }
    ) -join '&'
    $uri = "https://oauth.reddit.com/$($Path)?$queryString"

    $version = $MyInvocation.MyCommand.Module.Version
    $headers = @{
        Authorization = "bearer $Token"
        'User-Agent'  = "PSReddit/$version (by u/LukeEvansTech on GitHub)"
    }

    if ($DebugApi) { Write-Verbose "[DEBUG] Requesting: $uri" }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction Stop
    } catch {
        if ($DebugApi) {
            $httpResponse = $_.Exception.Response
            if ($httpResponse) {
                Write-Verbose "[DEBUG] Status: $([int]$httpResponse.StatusCode) $($httpResponse.StatusCode)"
            } else {
                Write-Verbose '[DEBUG] No HTTP response (the request did not reach Reddit).'
            }
            if ($_.ErrorDetails.Message) {
                Write-Verbose "[DEBUG] Body: $($_.ErrorDetails.Message)"
            }
        }
        Write-Error "Failed to retrieve posts for $Kind '$Name': $($_.Exception.Message)"
        return
    }

    if (-not $response.data.children) {
        Write-Error "No posts found or invalid $($Kind): $Name"
        return
    }

    foreach ($child in $response.data.children) {
        [PSCustomObject]$child.data
    }
}
