# Migration from MkDocs to Zensical

This document outlines the migration process from MkDocs to Zensical for the PSReddit documentation.

## Why Zensical?

Zensical is a modern documentation site generator built by the creators of Material for MkDocs. Key benefits include:

- **Better Performance**: Optimized for large documentation sites (10,000+ pages)
- **Simpler Configuration**: TOML-based configuration instead of YAML
- **Modern Architecture**: Built on the ZRX differential build engine
- **Maintained by Material Team**: From the creators of Material for MkDocs
- **Native Markdown**: No need for JSX or React knowledge
- **Built-in Material Design**: Modern, responsive theme out of the box

## What Changed

### New Files
- `zensical.toml` - Main Zensical configuration (replaces `mkdocs.yml`)
- `docs/package.json` - NPM scripts for running Zensical commands
- `docs/assets/stylesheets/custom.css` - Custom styling to hide Zensical branding

### Updated Files
- `docs/requirements.txt` - Now uses `zensical>=0.0.4` instead of MkDocs packages
- `.github/workflows/psreddit-deploy-docs.yml` - Updated to use Zensical build process
- `.gitignore` - Added `docs/site/` and `.zensical/` to ignore build artifacts
- `.readthedocs.yaml` - Updated to use Zensical build commands

### Preserved Files
- All markdown documentation files (`.md`) remain unchanged
- Documentation structure and navigation remain the same
- All content, examples, and code snippets are preserved

## Configuration Mapping

### MkDocs → Zensical Configuration

**Site Information:**
```yaml
# mkdocs.yml
site_name: PSReddit
site_url: https://LukeEvansTech.github.io/PSReddit/
```

```toml
# zensical.toml
[project]
site_name = "PSReddit"
site_url = "https://LukeEvansTech.github.io/PSReddit/"
```

**Theme Configuration:**
```yaml
# mkdocs.yml
theme:
  name: material
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: blue
```

```toml
# zensical.toml
[project.theme]
name = "material"
variant = "modern"

[[project.theme.palette]]
media = "(prefers-color-scheme: light)"
scheme = "default"
primary = "blue"
```

**Navigation:**
```yaml
# mkdocs.yml
nav:
  - Home: index.md
  - Cmdlets:
      - Get-RedditOAuthToken: Get-RedditOAuthToken.md
```

```toml
# zensical.toml
[[nav]]
Home = "index.md"

[[nav]]
Cmdlets = [
  { "Get-RedditOAuthToken" = "Get-RedditOAuthToken.md" }
]
```

## Development Workflow Changes

### Before (MkDocs)
```bash
# Install dependencies
pip install -r docs/requirements.txt

# Start dev server
mkdocs serve

# Build documentation
mkdocs build

# Deploy to GitHub Pages
mkdocs gh-deploy
```

### After (Zensical)
```bash
# Install dependencies
pip install -r docs/requirements.txt

# Start dev server
cd docs
npm start
# or: zensical serve

# Build documentation
npm run build
# or: zensical build

# Deploy (handled automatically by GitHub Actions)
```

## Deployment Changes

### GitHub Actions
The workflow now uses a two-job approach:
1. **Build Job**: Builds the site with Zensical and uploads artifact
2. **Deploy Job**: Deploys the artifact to GitHub Pages

Benefits:
- Better separation of concerns
- Pip caching for faster builds
- Only triggers on changes to `docs/**` or workflow file
- Manual trigger support via `workflow_dispatch`

### ReadTheDocs
ReadTheDocs configuration updated to use custom build commands:
```yaml
build:
  commands:
    - pip install -r docs/requirements.txt
    - cd docs && zensical build
    - mkdir -p $READTHEDOCS_OUTPUT/html
    - cp -r docs/site/* $READTHEDOCS_OUTPUT/html/
```

## Breaking Changes

None! The migration is designed to be seamless:
- All URLs remain the same
- All documentation content is preserved
- Navigation structure unchanged
- Same Material Design theme

## Rollback Instructions

If you need to rollback to MkDocs:

1. Restore the original `mkdocs.yml` file
2. Revert `docs/requirements.txt` to use MkDocs packages
3. Revert `.github/workflows/psreddit-deploy-docs.yml`
4. Delete `zensical.toml` and `docs/package.json`
5. Revert `.readthedocs.yaml` changes

The original MkDocs configuration can be found in the git history before this migration commit.

## Testing the Migration

To verify the migration was successful:

1. **Local Build Test:**
   ```bash
   cd docs
   pip install -r requirements.txt
   zensical build
   ```

2. **Check Output:**
   - Verify `docs/site/` directory was created
   - Open `docs/site/index.html` in a browser
   - Test all navigation links
   - Verify code syntax highlighting works
   - Check light/dark mode toggle

3. **GitHub Actions Test:**
   - Push changes to a branch
   - Verify the workflow runs successfully
   - Check GitHub Pages deployment

## Resources

- [Zensical Official Documentation](https://zensical.org/)
- [Material for MkDocs Documentation](https://squidfunk.github.io/mkdocs-material/)
- [github-infrastructure Migration Reference](https://github.com/LukeEvansTech/github-infrastructure/blob/main/docs/MIGRATION.md)

## Questions or Issues?

If you encounter any issues with the migration:
1. Check the build logs in GitHub Actions
2. Verify local build works correctly
3. Review the Zensical documentation
4. Compare with the github-infrastructure repository for reference
