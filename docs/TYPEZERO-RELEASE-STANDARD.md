# Typezer∅ Release Standard

## 1. Purpose

The Typezer∅ Release Standard defines consistent release metadata, version semantics, updater compatibility, naming, channels, verification, signing, source provenance, documentation, and rollback/recovery behavior across Typezer∅ application repositories.

It deliberately separates shared release policy from platform-specific installation mechanics.

CouchLink is the initial reference implementation and proving ground. Failure modes discovered there are promoted into ecosystem requirements and regression tests when they generalize beyond CouchLink.

## 2. Required repository elements

Every application repository should contain:

```text
CHANGELOG.md
docs/releases/
release-manifest.json
release build tooling
checksum generation tooling
release signing tooling or documented signing integration
release verification tooling
updater documentation
release validation record template
```

The exact source and tooling directories may vary by platform, but the resulting release must follow this standard.

## 3. Shared manifest concepts

Every published release manifest must identify:

- manifest schema version;
- stable application ID and display name;
- platform and architecture where applicable;
- Stable or Development channel;
- exact application version;
- publication date;
- minimum application version eligible for direct update;
- updater protocol version used by the release;
- minimum updater protocol version allowed to consume the release;
- mandatory or optional update status;
- release notes and changelog locations;
- exact downloadable asset names and sizes;
- SHA-256 digest for every downloadable payload;
- detached-signature metadata and signing-key identity;
- platform signing identity where applicable;
- source repository, Git tag, and source commit correspondence;
- rollback or recovery capability and policy.

The canonical machine-readable schema is `schemas/release-manifest.schema.json`.

## 4. Manifest schema and updater protocol are different

`schemaVersion` identifies the JSON manifest structure.

`updaterProtocolVersion` identifies the behavior and invocation contract expected by the release/updater pair.

`minimumUpdaterProtocolVersion` is the oldest updater protocol that may safely consume that release.

A schema may remain readable while an older updater is behaviorally incompatible. Conversely, a newer updater may support older schema revisions. Implementations must evaluate both independently.

See `docs/UPDATER-PROTOCOL-COMPATIBILITY.md`.

## 5. Release channels

### Stable

Stable releases are intended for normal users and must pass the complete release validation process.

Canonical manifest value:

```json
"channel": "stable"
```

### Development

Development releases are intended for testing and active development. They may be less stable, but they must satisfy the same identity, checksum, signature, source, and compatibility requirements.

Canonical manifest value:

```json
"channel": "development"
```

Applications may label this channel "Development" or "Test" in UI, but the manifest value remains `development`.

An application must not silently switch a user between Stable and Development.

## 6. Version policy

The ecosystem version comparator must support versions such as:

- `1.0`
- `1.1`
- `1.0.1`
- `1.3-dev.6`
- `1.3-dev.6.4`
- `2.7-dev.10.9.1`

Version components are compared numerically, not lexically. For example, `dev.10` is newer than `dev.9`, and `dev.6.4` is newer than `dev.6.3`.

Manifest versions, package/application versions, release asset filenames, release notes, and Git tags must correspond exactly under the rules in `docs/VERSION-COMPARISON-STANDARD.md`.

## 7. Update eligibility

An updater may offer a normal update only when all of the following are true:

1. manifest application identity matches the running application;
2. platform and architecture are compatible;
3. selected channel matches the manifest channel;
4. the target version is newer under the canonical comparator;
5. the installed application version satisfies `minimumVersion`;
6. the updater protocol is compatible with `minimumUpdaterProtocolVersion`;
7. an approved asset exists for the installation;
8. the manifest and asset originate from approved release locations;
9. required signing identities are trusted by local configuration.

If the installed version equals the manifest version, the result is **no update**. The updater must not reinstall the same version automatically.

If the target version is older, the updater must not present it as a normal update.

## 8. Asset naming

Use predictable, human-readable filenames.

Windows:

```text
App-Name-v<version>-win-x64.zip
App-Name-v<version>-win-x64.zip.sha256
App-Name-v<version>-win-x64.zip.sig
```

Android:

```text
App-Name-v<version>.apk
App-Name-v<version>.apk.sha256
App-Name-v<version>.apk.sig
```

The manifest must record the exact payload and detached-signature filenames and sizes.

See `docs/RELEASE-NAMING-STANDARD.md`.

## 9. Checksums and signatures

SHA-256 is mandatory for transfer integrity, but a checksum supplied by the same remote source as the payload is not sufficient publisher authentication.

Every published release payload must therefore carry detached-signature metadata. The application/updater must verify the signature using a locally trusted or pinned public key identity. A manifest-provided key ID or public-key fingerprint is expected metadata, not a trust anchor by itself.

Security-critical verification must be repeated at the final trust boundary. On Windows this means the updater independently verifies the payload immediately before replacement even when the main application already verified it.

See `docs/RELEASE-SIGNING-STANDARD.md`.

## 10. Source, tag, and release correspondence

A published release must identify the source repository, exact Git tag, and exact source commit used to build the payload.

The following must agree:

```text
manifest version
↔ release asset filename/version
↔ application/package version
↔ release notes
↔ Git tag
↔ tagged source commit
↔ published release
```

The canonical Git tag is `v<version>` unless an application has a documented exception.

Release verification must fail when the recorded tag does not resolve to the recorded commit or when the tag/version correspondence is wrong.

## 11. Mandatory updates

`mandatory: true` is reserved for releases that must replace an unsafe or unsupported version.

A mandatory update must provide a clear user-facing reason. It does not bypass checksum, signature, source, compatibility, package-signing, or operating-system permission requirements.

## 12. Minimum supported application version

`minimumVersion` identifies the oldest application version that may update directly to the listed release.

When an installed version is older, the updater must not guess. It should provide an explicit migration, bootstrap updater, or approved full-installer path.

## 13. Downgrade and rollback policy

- Never silently install a lower version.
- Never silently switch release channels.
- Do not automatically reinstall the currently installed version.
- User-selected downgrade paths require explicit support and confirmation.
- Rollback is a recovery operation, not ordinary version selection.
- Windows retains one previous known-good version for rollback.
- Android normally recovers by publishing a corrected higher version code with the same package ID and signing identity rather than automatic downgrade rollback.

See `docs/CHANNEL-AND-ROLLBACK-POLICY.md`.

## 14. Release documentation

Every release should include:

- an entry in `CHANGELOG.md`;
- dedicated release notes under `docs/releases/`;
- the release manifest;
- payload checksum files;
- detached signature files;
- known issues when applicable;
- upgrade or migration warnings when applicable;
- a completed release validation record.

## 15. Release validation

A release is not complete when the build succeeds. It must validate the full chain:

```text
source
→ version
→ build
→ package
→ checksum
→ signature
→ manifest
→ tag
→ publication
→ update discovery
→ valid update
→ restart or installer handoff
→ state preservation
→ no-update behavior
→ rollback/recovery
→ tamper rejection
→ legacy protocol compatibility
```

See `docs/RELEASE-VALIDATION-STANDARD.md`.

## 16. Security requirements

- Use HTTPS for remote manifests, payloads, and signatures.
- Pin or otherwise approve manifest/release origins in local trusted configuration.
- Treat downloaded manifests, payloads, and signature files as untrusted until validated.
- Reject unexpected application IDs, package IDs, platforms, architectures, filenames, sizes, hashes, signatures, signing keys, tags, and incompatible protocol versions.
- Do not execute downloaded content before verification.
- Do not use a remote manifest to redefine its own trust anchor silently.
- Never replace or weaken platform signing verification with checksum validation alone.
- Log update stages and failures without exposing secrets.

## 17. Standard maturity

This repository is pre-v1.0. Schema revision 2 is the current hardened manifest foundation. The first stable standards release should follow successful validation against CouchLink and at least one additional Typezer∅ application.
