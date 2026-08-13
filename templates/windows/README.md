# Windows Release Template

Copy this directory into a Windows application repository and replace placeholders.

The starter detached-signature scripts use OpenSSL. Equivalent application-specific signing tooling is allowed when it preserves the Typezer∅ manifest and trust semantics.

Suggested release workflow:

```powershell
./scripts/Build-Release.ps1 -Version 1.0 -Configuration Release -Runtime win-x64
./scripts/Sign-ReleaseAsset.ps1 `
  -AssetPath ./artifacts/release/1.0/AppName-v1.0-win-x64.zip `
  -PrivateKeyPath <trusted-private-key.pem>
./scripts/Generate-Manifest.ps1 `
  -Version 1.0 `
  -Channel stable `
  -DownloadBaseUrl https://example.invalid/releases/ `
  -SigningKeyId typezero-app-name-release-01 `
  -PublicKeyPath <trusted-public-key.pem>
# Create the canonical tag at the exact source commit recorded in the manifest before final verification.
git tag -a v1.0 -m "AppName v1.0"

./scripts/Verify-Release.ps1 `
  -ManifestPath ./artifacts/release/1.0/release-manifest.json `
  -AssetDirectory ./artifacts/release/1.0 `
  -PublicKeyPath <trusted-public-key.pem> `
  -ExpectedSigningKeyId typezero-app-name-release-01
```

Complete `docs/releases/RELEASE-VALIDATION-TEMPLATE.md` before publication.
