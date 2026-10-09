@{
    # The one PSScriptAnalyzer settings file: super-linter reads it from here, and
    # src/PSReddit.build.ps1 (Analyze task) and .vscode/settings.json point at it.
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning')
    # PSUseDeclaredVarsMoreThanAssignments excluded due to false positives with
    # Pester v5 scoping: assignments in a test file are consumed inside It/Should
    # blocks that PSScriptAnalyzer cannot see across scope.
    ExcludeRules        = @(
        'PSUseDeclaredVarsMoreThanAssignments'
    )
}
