# GitHub Workflows

PSReddit uses GitHub Actions to automate testing, documentation deployment, and module publishing. Below are the workflows and their triggers:

## Testing

- **PSReddit - Test on Linux** (`.github/workflows/psreddit-test-on-linux.yml`): runs on pull requests to validate module on Ubuntu.
- **PSReddit - Test on macOS** (`.github/workflows/psreddit-test-on-macos.yml`): runs on pull requests to validate module on macOS.
- **PSReddit - Test on Windows** (`.github/workflows/psreddit-test-on-windows.yml`): runs on pull requests to validate module on Windows.

## Documentation Deployment

- **PSReddit - Deploy Docs** (`.github/workflows/psreddit-deploy-docs.yml`): runs on push to `main` to build and publish the MkDocs site.

## Module Publishing

- **PSReddit - Publish Module** (`.github/workflows/psreddit-publish-module.yml`): runs on new release publishes to push the module to the PowerShell Gallery.
