@{
    # Mirrors src/PSScriptAnalyzerSettings.psd1 so super-linter applies the same
    # rules the repo already uses locally (super-linter reads its PSScriptAnalyzer
    # settings from .github/linters/, not from src/).
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning')
    # PSUseDeclaredVarsMoreThanAssignments excluded due to false positives with
    # Pester v5 scoping — assignments in a test file are consumed inside It/Should
    # blocks that PSScriptAnalyzer cannot see across scope.
    ExcludeRules        = @(
        'PSUseDeclaredVarsMoreThanAssignments'
    )
}
