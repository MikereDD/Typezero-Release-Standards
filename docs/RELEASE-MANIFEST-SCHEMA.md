# Release Manifest Schema Guide

The canonical machine-readable schema is located at:

```text
schemas/release-manifest.schema.json
```

## Core fields

| Field | Purpose |
|---|---|
| `schemaVersion` | Version of the manifest format. |
| `appId` | Stable lowercase application identifier. |
| `displayName` | Human-readable product name. |
| `platform` | `windows` or `android`. |
| `architecture` | Platform architecture or `universal`; optional where unnecessary. |
| `channel` | `stable` or `development`. |
| `version` | Exact application release version. |
| `publishedAt` | UTC ISO 8601 publication timestamp. |
| `minimumVersion` | Oldest version eligible for a direct update. |
| `mandatory` | Whether continued use requires the update. |
| `releaseNotesUrl` | HTTPS URL or repository-relative release-note path. |
| `assets` | One or more downloadable release assets. |
| `rollback` | Platform rollback capability and retention policy. |

## Asset fields

Every asset includes:

- `fileName`
- `downloadUrl`
- `size`
- `sha256`

Platform-specific fields may include:

- `packageId`
- `signingCertificateSha256`
- `authenticodeSignerThumbprint`

Unknown properties are rejected by the initial schema so accidental spelling errors do not silently pass validation.
