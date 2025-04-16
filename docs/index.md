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

## Author

Luke Evans