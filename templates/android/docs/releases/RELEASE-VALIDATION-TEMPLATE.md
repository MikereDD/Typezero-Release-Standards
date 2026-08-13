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

- APK: <filename>
- APK size: <bytes>
- APK SHA-256: <sha256>
- Detached signature: <filename.sig>
- Signature size: <bytes>
- Signature SHA-256: <sha256>
- Signature algorithm: <algorithm>
- Release signing key ID: <key id>
- Package ID: <package id>
- APK signing certificate SHA-256: <sha256>

## Validation

- [ ] Build completed successfully.
- [ ] APK filename/version matches manifest.
- [ ] APK size and SHA-256 match manifest.
- [ ] Detached signature verifies with pinned release key.
- [ ] Package ID matches installed application.
- [ ] APK signing certificate matches canonical pinned certificate.
- [ ] Git tag equals `v<version>` and resolves to recorded source commit.
- [ ] Release published with exact manifest assets.
- [ ] Supported older version discovers update.
- [ ] Multi-part development version comparison behaves correctly.
- [ ] Updater below minimum protocol rejects safely.
- [ ] Same-version manifest produces no update/reinstall.
- [ ] Downgrade candidate is rejected.
- [ ] Stable/Development mismatch is rejected.
- [ ] Android package installer handoff works.
- [ ] Installer cancellation cleans downloaded APK/signature files.
- [ ] User/application data are preserved during normal signed upgrade.
- [ ] Tampered APK is rejected.
- [ ] Tampered detached signature is rejected.
- [ ] Unapproved release key is rejected.
- [ ] APK signed by another certificate is rejected.

## Notes / deviations

None.
