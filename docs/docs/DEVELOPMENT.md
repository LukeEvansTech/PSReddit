# Development Guide

This guide provides instructions for building, testing, and developing the PSReddit module.

## Prerequisites

Before you begin, ensure you have the following installed:

*   **PowerShell 7+**: The module and build scripts require PowerShell 7 or later.
*   **Invoke-Build Module**: Used for automating build tasks. Install it using:
    ```powershell
    Install-Module Invoke-Build -Force
    ```
*   **Pester Module**: Used for running tests. The build script requires a version between 5.2.2 and 5.99.99. Install a compatible version (e.g., 5.5.0):
    ```powershell
    Install-Module Pester -RequiredVersion 5.5.0 -Force
    ```
*   **(Optional) Reddit API Credentials**: For running integration tests, you need a Reddit application Client ID and Secret. Set these as environment variables:
    ```powershell
    $env:REDDIT_CLIENT_ID = 'your-client-id'
    $env:REDDIT_CLIENT_SECRET = 'your-client-secret'
    ```

## Build Process

The build process is managed by `Invoke-Build` using the `src/PSReddit.build.ps1` script. All build commands should be run from the `src/` directory.

```powershell
cd src
```

### Full Build

Runs the default sequence: Clean, Validate Requirements, Import Module Manifest, Formatting Check, Analyze, Test (Unit), Create Help, Build, Integration Test, Archive.

```powershell
Invoke-Build
```

The final module output will be placed in the `src/Artifacts/PSReddit/` directory, and a zipped archive in `src/Archive/`.

### Build Without Integration Tests

Runs the full build process *except* for the integration tests.

```powershell
Invoke-Build BuildNoIntegration
```

## Testing

### Run Unit Tests

Runs static analysis (PSScriptAnalyzer) and Pester unit tests located in `src/Tests/Unit/`. Also generates code coverage reports.

```powershell
Invoke-Build TestLocal
```
*Or, to run only the Pester unit tests without analysis:*
```powershell
Invoke-Build Test
```
Test results (NUnit XML) and code coverage reports (JaCoCo XML) are saved in `src/Artifacts/`.

### Run Integration Tests

Runs Pester integration tests located in `src/Tests/Integration/`. These tests interact with the live Reddit API and require the `REDDIT_CLIENT_ID` and `REDDIT_CLIENT_SECRET` environment variables to be set.

```powershell
Invoke-Build IntegrationTest
```

### Code Coverage (for VSCode)

To generate a `cov.xml` file at the project root compatible with the "Coverage Gutters" VSCode extension:

```powershell
Invoke-Build DevCC
```

## Documentation

### Generate Help Files

To regenerate the markdown documentation and external help XML file (used by `Get-Help`):

```powershell
Invoke-Build HelpLocal
```
This runs the `Clean`, `ImportModuleManifest`, and `CreateHelpStart` tasks, including markdown and external help generation. The generated markdown files are placed in `src/Artifacts/docs/` and the XML help file in `src/Artifacts/en-US/`.

### Preview Documentation Site

This project uses Zensical with the Material theme. To preview the documentation site locally:

1.  Ensure you have Python and pip installed.
2.  Install Zensical:
    ```bash
    pip install -r docs/requirements.txt
    ```
3.  Navigate to the `docs/` directory:
    ```bash
    cd docs
    ```
4.  Run the Zensical development server:
    ```bash
    npm start
    # or directly: zensical serve
    ```
5.  Open your browser to `http://localhost:8000`.

### Build Documentation Site

To build the static documentation site:

```bash
cd docs
npm run build
# or directly: zensical build
```

The built site will be in the `docs/site/` directory.

## Cleaning

To remove the `src/Artifacts` and `src/Archive` directories:

```powershell
Invoke-Build Clean