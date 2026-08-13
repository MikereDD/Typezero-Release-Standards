# Release Validation — v<version>

## Identity

- Application: AppName
- Version: <version>
- Channel: <stable|development>
- Manifest schema: 2
- Updater protocol: <n>
- Minimum updater protocol: <n>
- Source repository: <url>
- Source commit: <full commit>
- Git tag: v<version>

## Artifact

- Payload: <filename>
- Payload size: <bytes>
- Payload SHA-256: <sha256>
- Detached signature: <filename.sig>
- Signature size: <bytes>
- Signature SHA-256: <sha256>
- Signature algorithm: <algorithm>
- Signing key ID: <key id>
- Authenticode signer: <thumbprint or N/A>

## Validation

- [ ] Build completed successfully.
- [ ] Package filename/version matches manifest.
- [ ] Payload size and SHA-256 match manifest.
- [ ] Detached signature verifies with pinned release key.
- [ ] Git tag equals `v<version>` and resolves to recorded source commit.
- [ ] Application/binary version corresponds to release version.
- [ ] Release published with exact manifest assets.
- [ ] Supported older version discovers update.
- [ ] Multi-part development version comparison behaves correctly.
- [ ] Compatible older updater protocol completes or follows documented migration path.
- [ ] Updater below minimum protocol rejects before replacement.
- [ ] Main app verifies payload and signature.
- [ ] Separate updater re-verifies payload and signature immediately before replacement.
- [ ] Process-already-exited case succeeds safely.
- [ ] Missing required updater arguments fail before replacement.
- [ ] Versioned payload filename cannot change installed target or restart path.
- [ ] Final installed critical-file hash matches verified staged source.
- [ ] Application restarts and completes transaction-scoped startup health check.
- [ ] User settings/data are preserved.
- [ ] Already-current version produces no update/reinstall.
- [ ] Rollback restores previous known-good version on simulated startup failure.
- [ ] Tampered payload is rejected.
- [ ] Tampered detached signature is rejected.
- [ ] Unapproved release key is rejected.

## Notes / deviations

None.
