# Typezer∅ Release Naming Standard

## Product name normalization

Use the public product name with spaces replaced by hyphens. Preserve recognizable capitalization.

Examples:

```text
MediaForge Studio → MediaForge-Studio
CouchLink         → CouchLink
Sariel            → Sariel
```

## Windows assets

```text
<Product>-v<version>-<runtime>.zip
<Product>-v<version>-<runtime>.zip.sha256
<Product>-v<version>-<runtime>.zip.sig
```

Example:

```text
MediaForge-Studio-v1.0-dev.30-win-x64.zip
MediaForge-Studio-v1.0-dev.30-win-x64.zip.sha256
MediaForge-Studio-v1.0-dev.30-win-x64.zip.sig
```

## Android assets

```text
<Product>-v<version>.apk
<Product>-v<version>.apk.sha256
<Product>-v<version>.apk.sig
```

Example:

```text
Sariel-v2.7-dev.1.apk
Sariel-v2.7-dev.1.apk.sha256
Sariel-v2.7-dev.1.apk.sig
```

## Git tags

The canonical release tag is:

```text
v<version>
```

Examples:

```text
v1.0
v1.3-dev.6.4
v2.7-dev.10.9.1
```

## Rules

- Do not use `latest` as the only version identifier in an artifact filename.
- Do not use spaces in downloadable artifact filenames.
- The filename version must exactly match the manifest version.
- Detached signature filenames normally append `.sig` to the complete payload filename.
- The Git tag must exactly match `v<manifest version>` unless a repository documents an approved exception.
- The manifest filename should remain `release-manifest.json` unless hosting requires channel-specific endpoints.
- Channel-specific endpoints may use `stable/release-manifest.json` and `development/release-manifest.json`.
- Release notes and validation records should include the exact release version in their filenames.
