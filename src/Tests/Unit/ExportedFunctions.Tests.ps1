BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'PSReddit'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    $manifestContent = Test-ModuleManifest -Path $PathToManifest
    # Get all exported functions
    $moduleExported = Get-Command -Module $ModuleName -CommandType Function | Select-Object -ExpandProperty Name
    $manifestExported = ($manifestContent.ExportedFunctions).Keys
}
BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'PSReddit'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    $manifestContent = Test-ModuleManifest -Path $PathToManifest
    # Get all exported functions
    $moduleExported = Get-Command -Module $ModuleName -CommandType Function | Select-Object -ExpandProperty Name
    $manifestExported = ($manifestContent.ExportedFunctions).Keys
}
Describe $ModuleName {

    Context 'Exported Commands' -Fixture {

        Context 'Number of commands' -Fixture {

            It 'Exports the same number of public functions as what is listed in the Module Manifest' {
                $manifestExported.Count | Should -BeExactly $moduleExported.Count
            }



        }

        Context 'Explicitly exported commands' {

            It 'Includes <_> in the Module Manifest ExportedFunctions' -ForEach $moduleExported {
                $manifestExported -contains $_ | Should -BeTrue
            }



        }
    } #context_ExportedCommands

    Context 'Command Help' -Fixture {
        Context '<_>' -ForEach $moduleExported {

            BeforeEach {
                $help = Get-Help -Name $_ -Full
            }

            It -Name 'Includes a Synopsis' -Test {
                $help.Synopsis | Should -Not -BeNullOrEmpty
            }

            It -Name 'Includes a Description' -Test {
                $help.description.Text | Should -Not -BeNullOrEmpty
            }

            It -Name 'Includes an Example' -Test {
                $help.examples.example | Should -Not -BeNullOrEmpty
            }
        }
    } #context_CommandHelp
    Context 'Function Logic' {

        # Mock Invoke-RestMethod for Get-RedditOAuthToken
        # Mocks moved inside individual 'It' blocks for better scoping
        It 'Get-RedditOAuthToken should return a token when credentials are present (mocked)' {
            # Mock Invoke-RestMethod specifically for the token endpoint for this test
            Mock Invoke-RestMethod -ModuleName PSReddit -ParameterFilter { $Uri -like '*api/v1/access_token*' -and $Method -eq 'Post' } -MockWith {
                Write-Verbose "Mocking Invoke-RestMethod for Token Request: $Uri"
                return @{ access_token = 'mock_token_123' }
            }

            # Set dummy environment variables for the test scope
            $env:REDDIT_CLIENT_ID = 'mock_client_id'
            $env:REDDIT_CLIENT_SECRET = 'mock_client_secret'

            $token = Get-RedditOAuthToken
            $token | Should -Be 'mock_token_123'

            # Clean up environment variables
            Remove-Item Env:\REDDIT_CLIENT_ID
            Remove-Item Env:\REDDIT_CLIENT_SECRET
        }

        It 'Get-RedditSubredditPost should return posts (mocked)' {
            # Mock Invoke-RestMethod specifically for the posts endpoint for this test
            Mock Invoke-RestMethod -ModuleName PSReddit -ParameterFilter { $Uri -like '*oauth.reddit.com*' } -MockWith {
                Write-Verbose "Mocking Invoke-RestMethod for Posts Request: $Uri"
                # Simulate successful post retrieval
                return @{
                    data = @{
                        children = @(
                            @{ data = @{ title = 'Mock Post 1'; score = 10; id = 'mp1' } }
                            @{ data = @{ title = 'Mock Post 2'; score = 20; id = 'mp2' } }
                        )
                    }
                }
            }

            # Mock Invoke-RestMethod specifically for the posts endpoint for this test
            Mock Invoke-RestMethod -ModuleName PSReddit -ParameterFilter { $Uri -like '*oauth.reddit.com*' } -MockWith {
                Write-Verbose "Mocking Invoke-RestMethod for Posts Request: $Uri"
                # Simulate successful post retrieval
                return @{
                    data = @{
                        children = @(
                            @{ data = @{ title = 'Mock Post 1'; score = 10; id = 'mp1' } }
                            @{ data = @{ title = 'Mock Post 2'; score = 20; id = 'mp2' } }
                        )
                    }
                }
            }

            # Mock Get-RedditOAuthToken specifically for this test
            Mock Get-RedditOAuthToken -ModuleName PSReddit -MockWith { return 'mock_token_for_getpost' }

            $posts = Get-RedditSubredditPost -Subreddit 'powershell' -Count 2
            $posts | Should -Not -BeNullOrEmpty
            $posts.Count | Should -Be 2
            $posts[0].title | Should -Be 'Mock Post 1'
            $posts[1].score | Should -Be 20
        }

        It 'Get-RedditUserPost should return user posts (mocked)' {
            # Mock Invoke-RestMethod specifically for the user posts endpoint
            Mock Invoke-RestMethod -ModuleName PSReddit -ParameterFilter { $Uri -like '*oauth.reddit.com/user/*' } -MockWith {
                Write-Verbose "Mocking Invoke-RestMethod for User Posts Request: $Uri"
                # Simulate successful user post retrieval
                return @{
                    data = @{
                        children = @(
                            @{ data = @{ title = 'User Post 1'; score = 15; id = 'up1' } }
                            @{ data = @{ title = 'User Post 2'; score = 25; id = 'up2' } }
                        )
                    }
                }
            }

            # Mock Get-RedditOAuthToken specifically for this test
            Mock Get-RedditOAuthToken -ModuleName PSReddit -MockWith { return 'mock_token_for_userpost' }

            $posts = Get-RedditUserPost -Username 'LukeEvansTech' -Count 2
            $posts | Should -Not -BeNullOrEmpty
            $posts.Count | Should -Be 2
            $posts[0].title | Should -Be 'User Post 1'
            $posts[1].score | Should -Be 25
        }
    } #context_FunctionLogic
}

