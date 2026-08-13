# Typezer∅ Android Updater Standard

## Recommended repository layout

```text
repo/
├── app/
├── tools/
│   ├── Build-Release.ps1
│   ├── Sign-ReleaseAsset.ps1
│   ├── Generate-Manifest.ps1
│   ├── Generate-Checksums.ps1
│   ├── Verify-DetachedSignature.ps1
│   ├── Verify-Release.ps1
│   ├── Verify-Package-Identity.ps1
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
AppName-v1.0.apk.sig
release-manifest.json
release-notes.md
release-validation.md
```

## Required sideloaded update flow

```text
Application
→ fetch manifest from an approved HTTPS origin
→ validate schema, app ID, platform, channel, exact version, and updater protocol compatibility
→ resolve the exact expected APK asset
→ download APK and detached signature to app-controlled temporary storage
→ verify exact APK/signature names and sizes
→ verify APK SHA-256
→ verify signature-file SHA-256
→ verify detached release signature with a pinned release key
→ inspect APK package ID
→ verify canonical APK signing certificate against the installed application and pinned expected identity
→ reject downgrade or same-version reinstall as a normal update
→ request installation through Android's package installer
→ Android presents required user confirmation
→ Android installs same-package/same-signing-identity update
→ application cleans abandoned/obsolete APK and signature files
```

## Mandatory rules

1. The APK package ID must exactly match the installed application.
2. The canonical signing certificate must match the installed application and the locally pinned expected signing identity.
3. APK SHA-256 must match the manifest.
4. Detached release-signature metadata must match locally trusted key configuration and the signature must verify cryptographically.
5. Never accept an APK or release signature authorized by an unapproved key.
6. The manifest and assets must come from approved HTTPS release origins. A remote manifest does not authorize a new origin by itself.
7. Validate `minimumUpdaterProtocolVersion` before downloading/installing an update that an older client cannot safely process.
8. Use Android's package installer; do not bypass platform installation controls.
9. Preserve application data through normal same-package, same-signing-key upgrades.
10. Support Stable and Development channels without silently switching channels.
11. Clearly distinguish update availability from installation permission.
12. Do not present the installed version as an update and do not silently downgrade.
13. Remove downloaded APK/signature files after successful installation when possible, and remove abandoned downloads after cancellation or expiration.
14. Use a scoped `FileProvider` or appropriate modern Android mechanism when exposing the APK to the installer.
15. Never log keystore passwords, private keys, signing secrets, or full security tokens.

## Signing identity

Android has two independent signing layers in this standard:

1. **Detached Typezer∅ release signature** — authenticates the published release payload before installer handoff.
2. **APK signing certificate** — authenticates Android package continuity and is enforced by Android during an upgrade.

Both must pass. SHA-256 alone is not sufficient.

The signing-certificate SHA-256 digest and release signing-key metadata are recorded in the manifest, but the updater compares them to locally trusted/pinned identities rather than trusting remote values by themselves.

## Approved release sources

Applications should pin or otherwise compile a set of approved manifest and asset origins. Redirects must be validated against that policy rather than followed to arbitrary hosts.

A manifest may describe where an asset is located, but it cannot expand the trust boundary silently.

## Android downgrade behavior

The updater must not present an older version as a normal update. Android may reject downgrades, and application data may be incompatible with older versions.

Automated rollback is therefore not part of the default Android standard. Recovery should normally publish a corrected APK with a higher Android version code, the same package ID, and the same signing identity.

## Required regression tests

At minimum test:

- multi-part Typezer∅ version comparison;
- same-version manifest produces no update;
- candidate downgrade is rejected;
- Stable/Development channel mismatch is rejected;
- updater below minimum protocol is rejected safely;
- altered APK is rejected;
- altered detached signature is rejected;
- unapproved release key is rejected;
- APK signed by another certificate is rejected;
- package-ID mismatch is rejected;
- installer cancellation cleans staging;
- normal signed upgrade preserves application data.
