# Typezer∅ Release Standard

## 1. Purpose

The Typezer∅ Release Standard defines consistent release metadata, naming, channels, verification, documentation, and rollback behavior across all Typezer∅ application repositories.

It deliberately separates shared release policy from platform-specific installation mechanics.

## 2. Required repository elements

Every application repository should contain:

```text
CHANGELOG.md
docs/releases/
release-manifest.json
release build tooling
checksum generation tooling
release verification tooling
updater documentation
```

The exact source and tooling directories may vary by platform, but the resulting release must follow this standard.

## 3. Shared manifest concepts

Every release manifest must identify:

- schema version
- application ID
- display name
- platform
- architecture where applicable
- release channel
- application version
- publication date
- minimum supported version
- mandatory or optional status
- release notes location
- downloadable assets
- SHA-256 digest for every downloadable asset
- signature metadata where applicable
- rollback capability and policy

The canonical schema is `schemas/release-manifest.schema.json`.

## 4. Release channels

### Stable

Stable releases are intended for normal users and must pass the repository's complete release verification process.

Canonical manifest value:

```json
"channel": "stable"
```

### Development

Development releases are intended for testing and active development. They may be less stable, but they must still satisfy checksum, identity, and signing requirements.

Canonical manifest value:

```json
"channel": "development"
```

An application must not silently switch a user from Stable to Development.

## 5. Version policy

Applications may use their established version format, including versions such as:

- `1.0`
- `1.1`
- `1.0-dev.30`
- `2.7-dev.4`

Manifest versions and asset filenames must match exactly.

Updaters must compare versions according to the application's documented version rules. Plain lexical string comparison is not sufficient.

## 6. Asset naming

Use predictable, human-readable filenames.

Windows:

```text
App-Name-v<version>-win-x64.zip
App-Name-v<version>-win-x64.zip.sha256
```

Android:

```text
App-Name-v<version>.apk
App-Name-v<version>.apk.sha256
```

Examples:

```text
MediaForge-Studio-v1.0-win-x64.zip
Cadence-Studio-v1.0-dev.30-win-x64.zip
CouchLink-v1.4.apk
Cloud-Player-v2.7.apk
```

## 7. Checksums

- Every downloadable archive or APK must have a SHA-256 digest.
- The digest must appear in the release manifest.
- A companion `.sha256` file should also be published.
- Installation must stop immediately when verification fails.
- Checksums must be generated after the final artifact is produced.

## 8. Mandatory updates

`mandatory: true` is reserved for releases that must replace an unsafe or unsupported version.

A mandatory update should provide a clear user-facing reason. It must not bypass platform security controls or install without the user interaction required by the operating system.

## 9. Minimum supported version

`minimumVersion` identifies the oldest version that may update directly to the listed release.

When an installed version is older, the updater should provide an explicit migration path or direct the user to a full installer rather than attempting an unsafe incremental update.

## 10. Downgrade and rollback policy

- An updater must never silently install a version lower than the installed version.
- User-selected downgrades require explicit confirmation and must be supported by the application.
- Rollback is a recovery operation, not ordinary version selection.
- Windows applications should retain one known previous version.
- Android rollback is normally not automated because Android package management and application-data compatibility constrain downgrade behavior.

See `docs/CHANNEL-AND-ROLLBACK-POLICY.md`.

## 11. Release documentation

Every release should include:

- an entry in `CHANGELOG.md`
- a dedicated release note under `docs/releases/`
- the release manifest
- asset checksums
- known issues when applicable
- upgrade or migration warnings when applicable

## 12. Security requirements

- Use HTTPS for remote manifests and assets.
- Treat downloaded manifests and artifacts as untrusted until validated.
- Reject unexpected application IDs, package IDs, platforms, architectures, filenames, hashes, and signatures.
- Do not execute downloaded content before verification.
- Never replace or weaken platform signing verification with checksum verification alone.
- Log failures without exposing secrets.

## 13. Standard versioning

Applications should record which revision of this standard they implement. A future `standardVersion` manifest property may be added when the ecosystem begins maintaining multiple schema revisions.
