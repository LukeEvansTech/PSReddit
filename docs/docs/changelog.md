# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.2.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `Get-RedditSubredditPost` without `-Sort` now uses the documented default (Top, last day); it used to request New.
- The built module in `src/Artifacts` (and the CI ZIP archive) exported only `Get-RedditSubredditPost`, because of a stray `Export-ModuleMember` in that function's file.

### Changed

- The two post commands share one private request helper, so the module is about half the size; the User-Agent now carries the module version.
- `-DebugApi` reports the HTTP status and Reddit's error body for a failed request.

### Added

- Unit tests for every public and private function (coverage floor raised from 30% to 90%), and a build check that the built module exports what the manifest lists.
- Integration tests now report as skipped, not passed, when Reddit credentials are missing.

### Known issues

- `Get-RedditUserPost -Sort Top` returns no posts against the live API (the integration test is skipped until this is fixed). The New sort works.

## [0.0.1]

### Added

- Initial release.

[Unreleased]: https://github.com/LukeEvansTech/PSReddit/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/LukeEvansTech/PSReddit/releases/tag/v0.0.1
