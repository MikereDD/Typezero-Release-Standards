# Typezer∅ Release Naming Standard

## Product name normalization

Use the public product name with spaces replaced by hyphens. Preserve recognizable capitalization.

Examples:

```text
MediaForge Studio → MediaForge-Studio
Cloud Player      → Cloud-Player
CouchLink         → CouchLink
```

## Windows assets

```text
<Product>-v<version>-<runtime>.zip
<Product>-v<version>-<runtime>.zip.sha256
```

Example:

```text
MediaForge-Studio-v1.0-dev.30-win-x64.zip
```

## Android assets

```text
<Product>-v<version>.apk
<Product>-v<version>.apk.sha256
```

Example:

```text
Cloud-Player-v2.7.apk
```

## Rules

- Do not use `latest` as the only version identifier in an artifact filename.
- Do not use spaces in downloadable artifact filenames.
- The filename version must exactly match the manifest version.
- The manifest filename should remain `release-manifest.json` unless a hosting layout requires channel-specific names.
- Channel-specific endpoints may use `stable/release-manifest.json` and `development/release-manifest.json`.
