# Typezer∅ Windows Updater Standard

## Recommended repository layout

```text
repo/
├── src/
├── updater/
│   └── AppName.Updater/
├── scripts/
│   ├── Build-Release.ps1
│   ├── Sign-ReleaseAsset.ps1
│   ├── Generate-Manifest.ps1
│   ├── Generate-Checksums.ps1
│   ├── Verify-DetachedSignature.ps1
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
AppName-v1.0-win-x64.zip.sig
release-manifest.json
release-notes.md
release-validation.md
```

## Required update flow

```text
Main application
→ fetch manifest from an approved HTTPS origin
→ validate schema, app ID, platform, channel, architecture, exact version, and updater protocol compatibility
→ resolve an approved asset with exact expected name and size
→ download ZIP and detached signature to randomized app-owned staging
→ verify ZIP SHA-256
→ verify signature-file SHA-256
→ verify detached signature with a pinned release key
→ validate optional Authenticode publisher identity where used
→ launch separate updater executable with explicit transaction data
→ close main application
→ treat an already-exited process as closed, not as a race failure
→ updater validates install root, target executable, restart path, source paths, and transaction ID
→ updater independently re-verifies ZIP SHA-256 and detached signature
→ back up the installed version
→ safely extract and validate staged content
→ replace files atomically where practical
→ prove critical final target hashes match verified staged sources
→ relaunch the known installed executable
→ wait for bounded startup-health confirmation
→ roll back on transaction-caused startup failure
```

## Mandatory rules

1. Never replace application files while the main application is running.
2. Use a separate updater executable or process.
3. Stage downloads below an application-owned temporary root using a randomized or cryptographically unique transaction directory.
4. Do not stage directly into the installation directory.
5. Validate source, extraction, target, backup, and restart paths before modification.
6. Reject path traversal, absolute archive entries, reparse-point/symlink escapes, and paths outside approved roots.
7. Bind replacement to the actual known installation and installed executable. A downloaded/versioned filename does not choose the install target.
8. Derive or validate the restart executable from trusted installed state, not from archive-controlled content.
9. Verify exact payload filename and size before use.
10. Verify payload SHA-256 in the main application and again in the updater immediately before replacement.
11. Verify the detached signature in the main application and again in the updater immediately before replacement using a pinned signing key.
12. Validate any configured Authenticode signer identity independently of the detached release signature.
13. If a supplied process ID no longer exists, treat that as already exited after validating the transaction/install identity; do not fail solely because the process ended before the wait began.
14. Validate every required updater argument before any destructive operation. Protocol-incompatible clients must fail before replacement.
15. Keep user settings and user data outside the replaceable installation directory.
16. Retain exactly one previous known-good version by default for rollback.
17. Use atomic file or directory replacement where practical.
18. After replacement, prove critical installed target files match the verified staged source bytes before relaunch.
19. Support Stable and Development channels without silently switching channels.
20. Never silently downgrade or automatically reinstall the same version.
21. Permit user-initiated update checks.
22. Clean abandoned staging directories safely without deleting outside the application-owned update root.
23. Log transaction ID, version transition, verification stages, replacement result, restart result, and rollback result without secrets.
24. Prevent automatic retry/rollback loops after a failed transaction.

## Installation and staging layout

Recommended conceptual layout:

```text
App installation/
├── current/
├── previous/
├── updater/
└── update-state.json

Application-owned temporary data/
└── updates/
    └── <random-transaction-id>/
        ├── payload/
        ├── extracted/
        └── transaction.json

User profile data/
└── AppName/
    ├── settings/
    ├── cache/
    └── logs/
```

Exact paths depend on packaging. The invariants are that staging is app-owned and randomized, mutable user data is not stored only in replaceable files, and update paths cannot escape approved roots.

## Process-exit handling

The updater may receive a process ID to coordinate shutdown, but a PID is not a durable identity by itself.

The updater should:

1. validate the expected installation/executable identity before replacement;
2. if the process exists, wait for bounded exit;
3. if the process has already exited, continue as a closed-state condition;
4. never terminate an unrelated process solely because a PID was reused;
5. abort when the running process identity conflicts with the expected application.

## Rollback health check

A release is not healthy merely because a process was created. The main application should signal successful initialization using a transaction-scoped success marker or equivalent authenticated/uniquely scoped handshake containing the new version and update transaction ID.

The updater should use a bounded startup timeout and roll back only when the current installation transaction caused the startup failure. It must avoid rollback loops.

## Final target verification

For critical files such as the main executable, the updater must compare the verified staged source hash with the installed target hash after replacement.

For multi-file packages, implementations should verify a signed or trusted extracted-file inventory where practical. A successful copy API return is not by itself proof that the intended bytes reached the intended target.

## Windows signing identities

Detached release signatures establish Typezer∅ release authorization. Authenticode, when used, establishes Windows publisher identity. They are independent controls and neither replaces the other.

The updater must not accept a new detached-signing key or Authenticode identity merely because a remote manifest requests it.

## Required regression tests

At minimum test:

- `dev.6.3` → `dev.6.4`-style multi-part version ordering;
- process exits before updater wait begins;
- missing newly required updater argument;
- versioned payload filename does not alter installed/restart path;
- altered payload rejected;
- altered detached signature rejected;
- unapproved release key rejected;
- final installed critical-file hash equals verified staged source;
- signed-to-signed upgrade;
- previous supported updater protocol → current release;
- updater below minimum protocol rejects before replacement;
- failed startup triggers one bounded rollback without a loop.
