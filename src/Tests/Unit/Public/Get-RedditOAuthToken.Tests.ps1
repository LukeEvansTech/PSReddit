BeforeAll {
    $manifest = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', '..', 'PSReddit', 'PSReddit.psd1')
    Get-Module -Name 'PSReddit' -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $manifest -Force
}

Describe 'Get-RedditOAuthToken' -Tag Unit {
    BeforeEach {
        $savedId = $env:REDDIT_CLIENT_ID
        $savedSecret = $env:REDDIT_CLIENT_SECRET
        $env:REDDIT_CLIENT_ID = 'test-id'
        $env:REDDIT_CLIENT_SECRET = 'test-secret'
    }
    AfterEach {
        $env:REDDIT_CLIENT_ID = $savedId
        $env:REDDIT_CLIENT_SECRET = $savedSecret
    }

    It 'returns the access token from the token endpoint' {
        Mock Invoke-RestMethod -ModuleName PSReddit { [pscustomobject]@{ access_token = 'tok-123' } }

        Get-RedditOAuthToken | Should -BeExactly 'tok-123'
    }

    It 'posts a client_credentials grant with HTTP Basic auth built from the environment' {
        Mock Invoke-RestMethod -ModuleName PSReddit { [pscustomobject]@{ access_token = 'tok' } }
        $expectedAuth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('test-id:test-secret'))

        $null = Get-RedditOAuthToken

        Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://www.reddit.com/api/v1/access_token' -and
            $Method -eq 'Post' -and
            $Headers.Authorization -eq $expectedAuth -and
            $Body.grant_type -eq 'client_credentials'
        }
    }

    It 'errors without calling Reddit when <Missing> is not set' -ForEach @(
        @{ Missing = 'REDDIT_CLIENT_ID' }
        @{ Missing = 'REDDIT_CLIENT_SECRET' }
    ) {
        Mock Invoke-RestMethod -ModuleName PSReddit { throw 'should not be called' }
        Set-Item -Path "Env:\$Missing" -Value ''

        $result = Get-RedditOAuthToken -ErrorVariable err -ErrorAction SilentlyContinue

        $result | Should -BeNullOrEmpty
        $err[0].Exception.Message | Should -Match 'environment variables must be set'
        Should -Invoke Invoke-RestMethod -ModuleName PSReddit -Times 0 -Exactly
    }

    It 'errors when the response has no access_token' {
        Mock Invoke-RestMethod -ModuleName PSReddit { [pscustomobject]@{ error = 'invalid_grant' } }

        $result = Get-RedditOAuthToken -ErrorVariable err -ErrorAction SilentlyContinue

        $result | Should -BeNullOrEmpty
        $err[0].Exception.Message | Should -Match 'Failed to retrieve access token'
    }

    It 'errors when the token request fails' {
        Mock Invoke-RestMethod -ModuleName PSReddit { throw 'connection refused' }

        $result = Get-RedditOAuthToken -ErrorVariable err -ErrorAction SilentlyContinue

        $result | Should -BeNullOrEmpty
        $err.Exception.Message | Should -Contain 'OAuth token request failed: connection refused'
    }
}
