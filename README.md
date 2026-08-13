# Typezer∅ Release Standards

A reusable release, update, verification, signing, compatibility, and rollback foundation for the Typezer∅ application ecosystem.

This repository defines one shared release philosophy with two platform-specific implementations:

- **Windows:** archive-based updates applied by a separate updater executable, with staged verification, backup, restart validation, and rollback.
- **Android:** signed APK updates validated by release signature, checksum, package identity, and signing certificate before Android's package installer is invoked.

Application repositories may implement their updater differently where platform or product needs require it, but they must preserve the common manifest semantics, version rules, updater-protocol compatibility, release channels, asset naming, checksums, signing identity, source/tag correspondence, rollback/recovery policy, validation records, and documentation structure defined here.

## Reference implementation

**CouchLink is the initial reference implementation and proving ground for the Typezer∅ Release Standards.**

Real updater failures discovered during CouchLink development are converted into ecosystem-wide requirements and regression cases here. The goal is to discover a failure mode once, document it once, and prevent future Typezer∅ Windows and Android applications from repeating it.

See [`docs/COUCHLINK-REFERENCE-IMPLEMENTATION.md`](docs/COUCHLINK-REFERENCE-IMPLEMENTATION.md).

## Start here

1. Read [`docs/TYPEZERO-RELEASE-STANDARD.md`](docs/TYPEZERO-RELEASE-STANDARD.md).
2. Read the shared protocol and security rules:
   - [`docs/VERSION-COMPARISON-STANDARD.md`](docs/VERSION-COMPARISON-STANDARD.md)
   - [`docs/UPDATER-PROTOCOL-COMPATIBILITY.md`](docs/UPDATER-PROTOCOL-COMPATIBILITY.md)
   - [`docs/RELEASE-SIGNING-STANDARD.md`](docs/RELEASE-SIGNING-STANDARD.md)
   - [`docs/RELEASE-VALIDATION-STANDARD.md`](docs/RELEASE-VALIDATION-STANDARD.md)
3. Choose the applicable platform guide:
   - [`docs/WINDOWS-UPDATER-STANDARD.md`](docs/WINDOWS-UPDATER-STANDARD.md)
   - [`docs/ANDROID-UPDATER-STANDARD.md`](docs/ANDROID-UPDATER-STANDARD.md)
4. Copy the matching directory from `templates/` into the application repository.
5. Replace placeholder values such as `AppName`, `app-name`, signing-key identities, and example URLs.
6. Validate the generated manifest against `schemas/release-manifest.schema.json` and complete a release validation record before publication.

## Repository contents

```text
Typezero-Release-Standards/
├── CHANGELOG.md
├── docs/
│   ├── TYPEZERO-RELEASE-STANDARD.md
│   ├── WINDOWS-UPDATER-STANDARD.md
│   ├── ANDROID-UPDATER-STANDARD.md
│   ├── VERSION-COMPARISON-STANDARD.md
│   ├── UPDATER-PROTOCOL-COMPATIBILITY.md
│   ├── RELEASE-SIGNING-STANDARD.md
│   ├── RELEASE-VALIDATION-STANDARD.md
│   └── COUCHLINK-REFERENCE-IMPLEMENTATION.md
├── schemas/
├── examples/
└── templates/
    ├── windows/
    └── android/
```

## Canonical principles

- Version comparison is numeric and exact, including multi-part development builds such as `1.3-dev.6.4`.
- Stable and Development channels remain separate; no updater silently changes channels or downgrades.
- Updater protocol compatibility is declared explicitly before new required arguments or fields are used.
- Every downloaded release payload is verified before installation, and security-critical verification is repeated at the final trust boundary.
- Release assets carry exact names, sizes, SHA-256 hashes, detached-signature metadata, and signing-key identity.
- The updater trusts pinned signing keys and approved release origins, not key identities supplied only by the remote manifest.
- Published version, release assets, source commit, and Git tag must correspond.
- User data and settings live outside replaceable application files.
- Windows retains one known previous version for rollback and verifies replacement against the intended installed target.
- Android accepts only the expected package ID and canonical signing certificate and uses the Android system package installer.
- Every release has a reproducible validation record covering success, no-update, recovery, compatibility, and tamper-rejection paths.

## Manifest generation

The current schema revision is **2**. It adds updater protocol compatibility, source provenance, changelog metadata, and detached release signatures to the original manifest foundation.

A release manifest declares both:

```json
"updaterProtocolVersion": 2,
"minimumUpdaterProtocolVersion": 1
```

An updater whose protocol version is below `minimumUpdaterProtocolVersion` must reject the update safely and direct the user to an approved compatibility path rather than attempting an update it cannot interpret.

## Status

See [`CHANGELOG.md`](CHANGELOG.md) for standards changes.

The standard is **pre-v1.0 and under active hardening**. CouchLink is the first reference implementation. The first stable standards release should follow successful application of the hardened rules to CouchLink and at least one additional Typezer∅ application.
