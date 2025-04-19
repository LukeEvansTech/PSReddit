---
external help file: PSReddit-help.xml
Module Name: PSReddit
online version:
schema: 2.0.0
---

# Get-RedditUserPost

## SYNOPSIS

Retrieves posts submitted by specific Reddit users.

## SYNTAX

```powershell
Get-RedditUserPost [-Username] <String[]> [[-Sort] <String>] [-LastHour] [-LastDay] [-LastWeek] [-LastMonth]
 [-LastYear] [-AllTime] [[-Count] <Int32>] [-DebugApi]
 [<CommonParameters>]
```

## DESCRIPTION

Uses Reddit's API and OAuth2 to fetch posts made by specified Reddit user(s).
You can specify the sort type (Top, New, Hot, Controversial) and limit the number of posts.
Timeframe switches (-LastHour, -LastDay, etc.) apply to 'Top' and 'Controversial' sorts, per Reddit API rules.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-RedditUserPost -Username 'LukeEvansTech' -Sort New -Count 10
```

### EXAMPLE 2

```powershell
Get-RedditUserPost -Username 'LukeEvansTech' -Sort Top -LastWeek
```

## PARAMETERS

### -Username

One or more Reddit usernames (without u/).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort

Sort type: Top, New, Hot, or Controversial.
Default is New.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: New
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastHour

Retrieve posts from the last hour (Top/Controversial only).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastDay

Retrieve posts from the last day (Top/Controversial only).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastWeek

Retrieve posts from the last week (Top/Controversial only).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastMonth

Retrieve posts from the last month (Top/Controversial only).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastYear

Retrieve posts from the last year (Top/Controversial only).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllTime

Retrieve posts from all time (default; Top/Controversial only).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count

Number of posts to retrieve per user (max 100, default 25).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
```

### -DebugApi

If specified, outputs verbose debugging information about the API requests and responses.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Reddit's API only allows one sort and (if applicable) one timeframe per request.
Timeframes only apply to 'Top' and 'Controversial' sorts.

## RELATED LINKS
