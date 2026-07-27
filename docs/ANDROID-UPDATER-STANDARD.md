# Typezer∅ Android Updater Standard

## Recommended repository layout

```text
repo/
├── app/
├── tools/
│   ├── Build-Release.ps1
│   ├── Generate-Manifest.ps1
│   ├── Generate-Checksums.ps1
│   └── Verify-Signing-Certificate.ps1
├── docs/
│   └── releases/
├── CHANGELOG.md
└── release-manifest.json
```

## Release contents

```text
AppName-v1.0.apk
AppName-v1.0.apk.sha256
release-manifest.json
release-notes.md
```

## Required sideloaded update flow

```text
Application
→ fetch manifest over HTTPS
→ validate app ID, platform, channel, and version
→ download APK to app-controlled temporary storage
→ verify APK SHA-256
→ verify APK package ID
→ verify signing certificate against the installed application and expected manifest value
→ request installation through Android's package installer
→ Android presents required user confirmation
→ Android installs the update
→ application removes abandoned or obsolete APK files
```

## Mandatory rules

1. The APK package ID must match the installed application.
2. The signing certificate must match the installed application.
3. The signing certificate must also match the pinned expected certificate identity when the app uses certificate pinning.
4. The APK SHA-256 must match the manifest.
5. Never accept an APK signed by a different key.
6. Use Android's package installer; do not attempt to bypass platform installation controls.
7. Preserve application data through normal same-package, same-signing-key upgrades.
8. Support Stable and Development channels without silently switching channels.
9. Clearly distinguish update availability from installation permission.
10. Remove downloaded APKs after successful installation when possible, and remove abandoned downloads after cancellation or expiration.
11. Use a scoped `FileProvider` or appropriate modern Android mechanism when exposing the APK to the installer.
12. Never log keystore passwords, private keys, or signing secrets.

## Signing identity

The signing certificate SHA-256 digest should be recorded in the manifest asset metadata and pinned in the application or a trusted build-time configuration.

Checksum validation alone is not sufficient. An attacker who can replace both a manifest and APK could provide matching checksums. Signing-certificate identity is therefore a separate mandatory control.

## Android downgrade behavior

The updater must not present an older version as a normal update. Android may reject downgrades, and application data may be incompatible with older versions. Automated rollback is therefore not part of the default Android standard.

Recovery builds must be explicitly documented and installed through supported Android mechanisms.
