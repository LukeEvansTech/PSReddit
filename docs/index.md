# PSReddit

## Synopsis

PSReddit is a PowerShell module for interacting with the Reddit API.

## Documentation

You are currently viewing the online documentation at [https://lukeevanstech.github.io/PSReddit/](https://lukeevanstech.github.io/PSReddit/)

## Description

This module provides cmdlets to authenticate with Reddit, retrieve posts from subreddits and users, and interact with the Reddit API directly from PowerShell.

## Why

To provide a simple and PowerShell-idiomatic way to automate Reddit interactions.

## Getting Started

### Prerequisites

PowerShell 7 or later. A Reddit account and API credentials (client ID, client secret).

### Installation

```powershell
Install-Module -Name PSReddit

```

### Quick start

#### Example 1: Get subreddit posts

```powershell
Get-RedditSubredditPost -Subreddit 'PowerShell' -Count 10
```

#### Example 2: Get user posts

```powershell
Get-RedditUserPost -Username 'LukeEvansTech' -Sort Top -LastWeek -Count 5
```

## Cmdlet Reference

- [Get-RedditOAuthToken](Get-RedditOAuthToken.md) – Retrieves an OAuth2 bearer token from Reddit.
- [Get-RedditSubredditPost](Get-RedditSubredditPost.md) – Retrieves posts from one or more subreddits.
- [Get-RedditUserPost](Get-RedditUserPost.md) – Retrieves posts submitted by specific Reddit users.
+For full details including parameter tables and usage examples, refer to each cmdlet’s documentation page.

## Author

Luke Evans