# Windows Release Template

Copy this directory into a Windows application repository and replace placeholders.

Suggested workflow:

```powershell
./scripts/Build-Release.ps1 -Version 1.0 -Configuration Release -Runtime win-x64
./scripts/Generate-Manifest.ps1 -Version 1.0 -Channel stable
./scripts/Verify-Release.ps1
```
