# Android Release Template

Copy this directory into an Android application repository and replace placeholders.

Suggested workflow:

```powershell
./tools/Build-Release.ps1 -Version 1.0
./tools/Generate-Manifest.ps1 -Version 1.0 -Channel stable
./tools/Verify-Signing-Certificate.ps1 -ApkPath ./artifacts/release/1.0/AppName-v1.0.apk
```
