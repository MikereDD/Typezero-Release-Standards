# Typezer∅ Release Standards

A reusable release and updater foundation for the Typezer∅ application ecosystem.

This repository defines one shared release philosophy with two platform-specific implementations:

- **Windows:** archive-based updates applied by a separate updater executable, with backup and rollback.
- **Android:** signed APK updates validated by checksum, package identity, and signing certificate before Android's package installer is invoked.

Application repositories may implement their updater differently where necessary, but they should preserve the common manifest, release channels, asset naming, checksums, verification rules, rollback policy, and documentation structure defined here.

## Start here

1. Read [`docs/TYPEZERO-RELEASE-STANDARD.md`](docs/TYPEZERO-RELEASE-STANDARD.md).
2. Choose the applicable platform guide:
   - [`docs/WINDOWS-UPDATER-STANDARD.md`](docs/WINDOWS-UPDATER-STANDARD.md)
   - [`docs/ANDROID-UPDATER-STANDARD.md`](docs/ANDROID-UPDATER-STANDARD.md)
3. Copy the matching directory from `templates/` into the application repository.
4. Replace all placeholder values such as `AppName`, `app-name`, and example URLs.
5. Validate the generated manifest against `schemas/release-manifest.schema.json`.

## Repository contents

```text
Typezero-Release-Standards/
├── docs/
├── schemas/
├── examples/
├── templates/
│   ├── windows/
│   └── android/
└── README.md
```

## Canonical principles

- Every downloaded release asset is verified before installation.
- Stable and Development channels remain separate.
- Updates never silently downgrade an installation.
- User data and settings live outside replaceable application files.
- Windows retains one known previous version for rollback.
- Android accepts only the expected package ID and signing certificate.
- Release artifacts use predictable names across all Typezer∅ applications.

## Status

This is the initial ecosystem standard and repository template. Application-specific implementations should cite the standard version they follow.
