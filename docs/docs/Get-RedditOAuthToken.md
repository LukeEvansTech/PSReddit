---
external help file: PSReddit-help.xml
Module Name: PSReddit
online version:
schema: 2.0.0
---

# Get-RedditOAuthToken

## SYNOPSIS

Retrieves an OAuth2 bearer token from Reddit.

## SYNTAX

```powershell
Get-RedditOAuthToken [<CommonParameters>]
```

## DESCRIPTION

Authenticates with Reddit using client credentials from environment variables (REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET).

## EXAMPLES

### EXAMPLE 1

```powershell
$token = Get-RedditOAuthToken
```

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Requires environment variables REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET to be set.

## RELATED LINKS
