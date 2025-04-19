# PSReddit

## Synopsis

A cross-platform PowerShell 7+ module for authenticating with Reddit and retrieving posts from subreddits.

## Description

This module provides cmdlets to authenticate with the Reddit API using OAuth 2.0 client credentials flow and fetch posts based on subreddit, sort order, and timeframe. It requires PowerShell 7+ and relies on environment variables for storing Reddit API client ID and secret.

## Why

<!-- Short reason you created the project -->

## Features
- OAuth authentication (using environment variables for secrets)
- Retrieve posts by subreddit, sort type (Top, New, Hot, etc.), and timeframe (for Top/Controversial)
- Pester tests for integration testing
- MkDocs documentation structure

## Getting Started

### Prerequisites

- PowerShell 7+
- Reddit API Client ID and Secret stored in environment variables:
  - `REDDIT_CLIENT_ID`
  - `REDDIT_CLIENT_SECRET`

### Installation

```powershell
# Import the module locally from the source directory
Import-Module ./src/PSReddit/PSReddit.psd1 -Force
```

### Quick start (Usage Example)

```powershell
# Set environment variables (replace with your actual credentials)
$env:REDDIT_CLIENT_ID = 'your-client-id'
$env:REDDIT_CLIENT_SECRET = 'your-client-secret'

# Get an OAuth token
$token = Get-RedditOAuthToken

# Get the top 5 posts from the 'powershell' subreddit from the last day
$posts = Get-RedditSubredditPost -Subreddit 'powershell' -Sort Top -LastDay -Count 5

# Display post titles
$posts.title
```

## Docs
See the [documentation](./docs/index.md) for full usage, installation, and development information.

## Development
- Run tests: `Invoke-Pester ./src/Tests -CI` (Ensure Pester module is installed)
- Style Guides: Refer to project configuration files (e.g., `.editorconfig`, `PSScriptAnalyzerSettings.psd1`).
- Contributions welcome! Please follow standard fork & pull request workflow.

## Author

Luke Evans
