# Android Release Template

Copy this directory into an Android application repository and replace placeholders.

The starter detached-signature scripts use OpenSSL. APK signing remains a separate Android requirement and is verified independently.

Suggested release workflow:

```powershell
./tools/Build-Release.ps1 -Version 1.0
./tools/Sign-ReleaseAsset.ps1 `
  -AssetPath ./artifacts/release/1.0/AppName-v1.0.apk `
  -PrivateKeyPath <trusted-private-key.pem>
./tools/Generate-Manifest.ps1 `
  -Version 1.0 `
  -Channel stable `
  -PackageId com.typezero.appname `
  -SigningCertificateSha256 <apk-certificate-sha256> `
  -DownloadBaseUrl https://example.invalid/releases/ `
  -SigningKeyId typezero-app-name-release-01 `
  -PublicKeyPath <trusted-public-key.pem>
# Create the canonical tag at the exact source commit recorded in the manifest before final verification.
git tag -a v1.0 -m "AppName v1.0"

./tools/Verify-Release.ps1 `
  -ManifestPath ./artifacts/release/1.0/release-manifest.json `
  -AssetDirectory ./artifacts/release/1.0 `
  -PublicKeyPath <trusted-public-key.pem> `
  -ExpectedSigningKeyId typezero-app-name-release-01
```

Complete `docs/releases/RELEASE-VALIDATION-TEMPLATE.md` before publication.
