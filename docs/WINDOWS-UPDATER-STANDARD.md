# Typezer∅ Windows Updater Standard

## Recommended repository layout

```text
repo/
├── src/
├── updater/
│   └── AppName.Updater/
├── scripts/
│   ├── Build-Release.ps1
│   ├── Generate-Manifest.ps1
│   ├── Generate-Checksums.ps1
│   └── Verify-Release.ps1
├── docs/
│   └── releases/
├── CHANGELOG.md
└── release-manifest.json
```

## Release contents

```text
AppName-v1.0-win-x64.zip
AppName-v1.0-win-x64.zip.sha256
release-manifest.json
release-notes.md
```

## Required update flow

```text
Main application
→ fetch manifest over HTTPS
→ validate app ID, platform, channel, architecture, and version
→ download release ZIP to a temporary location
→ verify SHA-256
→ launch separate updater executable
→ request the main application to close
→ confirm the process has exited
→ back up the installed version
→ replace application files
→ relaunch the application
→ verify successful startup
→ roll back when startup verification fails
```

## Mandatory rules

1. Never replace application files while the main application is running.
2. Use a separate updater executable or process.
3. Keep user settings and user data outside the replaceable installation directory.
4. Retain one previous known-good version for rollback.
5. Verify every downloaded archive before extraction.
6. Reject path traversal and unsafe archive entries during extraction.
7. Use atomic file or directory replacement where practical.
8. Support Stable and Development channels without silently switching channels.
9. Permit user-initiated update checks.
10. Never silently downgrade.
11. Clean abandoned downloads and staging directories safely.
12. Log update stages and failures without recording secrets.

## Installation layout

Recommended conceptual layout:

```text
App installation/
├── current/
├── previous/
├── updater/
└── update-state.json

User profile data/
└── AppName/
    ├── settings/
    ├── cache/
    └── logs/
```

The exact paths depend on packaging, but mutable user data must not be stored only inside the replaceable application directory.

## Rollback health check

A release is not considered healthy merely because its process started. The main application should signal successful initialization to the updater, for example by writing an authenticated or uniquely scoped success marker containing the new version and update transaction ID.

The updater should use a bounded startup timeout and roll back only when the installation transaction itself caused a failed startup. It must avoid rollback loops.

## Windows signature metadata

SHA-256 validates asset integrity against the manifest. Authenticode signing, when available, establishes publisher identity and should be validated independently. The manifest may record the expected signer certificate thumbprint.
