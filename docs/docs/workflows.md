# GitHub Workflows

PSReddit uses GitHub Actions to automate testing, documentation deployment, and module publishing. Below are the workflows and their triggers:

## Testing

- **PSReddit - Test** (`.github/workflows/psreddit-test.yml`): runs the full `Invoke-Build` (formatting, PSScriptAnalyzer, unit tests with a 90% coverage floor, help, build, built-module export check, integration tests) on Ubuntu, Windows and macOS for every pull request and push to `main` that touches code.
- **Lint** (`.github/workflows/lint.yml`): runs super-linter, including PSScriptAnalyzer with `.github/linters/.powershell-psscriptanalyzer.psd1`.

## Documentation Deployment

- **PSReddit - Deploy Docs** (`.github/workflows/psreddit-deploy-docs.yml`): runs on push to `main` to build and publish the MkDocs site.

## Module Publishing

- **PSReddit - Publish Module** (`.github/workflows/psreddit-publish-module.yml`): runs on new release publishes to push the module to the PowerShell Gallery.
