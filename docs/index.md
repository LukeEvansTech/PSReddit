# PSReddit

## Synopsis

PSReddit is a PowerShell module for interacting with the Reddit API.

## Description

This module provides cmdlets to authenticate with Reddit, retrieve posts, submit content, and perform other common Reddit actions directly from PowerShell.

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

#### Example1

```powershell
Get-RedditPost -Subreddit 'PowerShell' -Limit 10

```

## Cmdlet Reference

- [Get-RedditOAuthToken](Get-RedditOAuthToken.md) – Retrieves an OAuth2 bearer token from Reddit.
- [Get-RedditPost](Get-RedditPost.md) – Retrieves posts from one or more subreddits.
+For full details including parameter tables and usage examples, refer to each cmdlet’s documentation page.

## Author

Luke Evans