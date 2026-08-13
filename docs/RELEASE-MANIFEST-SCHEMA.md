# Release Manifest Schema Guide

The canonical machine-readable schema is located at:

```text
schemas/release-manifest.schema.json
```

The current manifest schema revision is **2**.

## Core fields

| Field | Purpose |
|---|---|
| `schemaVersion` | Version of the JSON manifest structure. |
| `appId` | Stable lowercase application identifier. |
| `displayName` | Human-readable product name. |
| `platform` | `windows` or `android`. |
| `architecture` | Platform architecture or universal target. |
| `channel` | `stable` or `development`. |
| `version` | Exact application release version under the Typezer∅ version grammar. |
| `publishedAt` | UTC ISO 8601 publication timestamp. |
| `minimumVersion` | Oldest application version eligible for direct update. |
| `updaterProtocolVersion` | Updater/release contract revision used by the target release. |
| `minimumUpdaterProtocolVersion` | Oldest updater protocol allowed to consume the release safely. |
| `mandatory` | Whether continued use requires the update. |
| `mandatoryReason` | Required human-readable reason when `mandatory` is true. |
| `releaseNotesUrl` | HTTPS URL or safe repository-relative release-note path. |
| `changelogUrl` | HTTPS URL or safe repository-relative changelog path. |
| `assets` | One or more downloadable release payloads. |
| `source` | Source repository, Git tag, and exact source commit. |
| `rollback` | Platform rollback/recovery capability and retention policy. |

## Asset fields

Every payload asset includes:

- `fileName`
- `downloadUrl`
- `size`
- `sha256`
- `signature`

Android assets additionally require:

- `packageId`
- `signingCertificateSha256`

Windows assets may additionally declare:

- `authenticodeSignerThumbprint`

## Detached signature fields

Every `signature` object includes:

- `algorithm`
- `fileName`
- `downloadUrl`
- `size`
- `sha256`
- `keyId`
- `publicKeySha256`

`publicKeySha256` is the SHA-256 fingerprint of the canonical DER SubjectPublicKeyInfo bytes for the public key. The public-key fingerprint and key ID in the manifest are expected metadata. The updater must compare them with a locally trusted/pinned key configuration. They are not trusted merely because they came from the manifest.

## Source fields

`source` includes:

- `repositoryUrl`
- `tag`
- `commit`

The schema validates their shape. Release verification must additionally prove semantic correspondence that JSON Schema cannot express, including:

```text
source.tag == "v" + version
source.tag resolves to source.commit
asset filename contains the exact release version
minimumUpdaterProtocolVersion <= updaterProtocolVersion
```

## Version grammar

Schema revision 2 accepts the canonical Stable and Development forms described in `docs/VERSION-COMPARISON-STANDARD.md`, including multi-part development builds such as:

```text
1.3-dev.6.4
2.7-dev.10.9.1
```

## Unknown properties

Unknown properties are rejected by the schema. This prevents misspelled security or compatibility fields from silently passing validation.

When a new required field or behavior would break older updater clients, increment the applicable schema and/or updater protocol and document the compatibility transition.
