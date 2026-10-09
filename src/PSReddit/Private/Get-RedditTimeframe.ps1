<#
.SYNOPSIS
    Resolves the Reddit 't' (timeframe) query value from a command's timeframe switches.
.DESCRIPTION
    Reddit only honours a timeframe on the Top and Controversial sorts, so any other sort
    returns $null. When several switches are set, the shortest timeframe wins.
#>
function Get-RedditTimeframe {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [string]$Sort,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$BoundParameters,

        [Parameter(Mandatory)]
        [ValidateSet('hour', 'day', 'week', 'month', 'year', 'all')]
        [string]$Default
    )

    if ($Sort -notin @('Top', 'Controversial')) {
        return $null
    }

    $switchMap = [ordered]@{
        LastHour  = 'hour'
        LastDay   = 'day'
        LastWeek  = 'week'
        LastMonth = 'month'
        LastYear  = 'year'
        AllTime   = 'all'
    }
    foreach ($name in $switchMap.Keys) {
        if ($BoundParameters[$name]) {
            return $switchMap[$name]
        }
    }
    return $Default
}
