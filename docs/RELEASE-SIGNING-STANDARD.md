# Typezer∅ Release Signing Standard

## Purpose

SHA-256 proves that downloaded bytes match a recorded digest. It does not prove who authorized those bytes when an attacker can replace both the payload and the remote manifest.

Every Typezer∅ release payload therefore carries detached-signature metadata in addition to its SHA-256 checksum and any platform signing identity.

## Required asset signature metadata

Each manifest asset includes a `signature` object containing:

- signing algorithm;
- exact signature filename;
- signature download URL;
- exact signature-file size;
- SHA-256 of the detached signature file;
- stable release signing-key ID;
- SHA-256 fingerprint of the canonical DER SubjectPublicKeyInfo representation of the expected public key.

The signature filename should normally be the payload filename plus `.sig`. The public-key fingerprint is calculated from canonical DER SubjectPublicKeyInfo bytes so PEM formatting and line-ending changes do not change key identity.

## Trust model

The updater must not trust a public key merely because the remote manifest names it.

The application/updater must contain or obtain through an independently trusted mechanism:

- an approved signing-key ID;
- the corresponding public key or a pinned fingerprint;
- allowed signature algorithms;
- key-rotation rules.

Manifest signature metadata is compared with that local trust configuration. It does not replace it.

## Verification order

Recommended order:

```text
fetch manifest from approved origin
→ validate manifest identity and protocol
→ download payload and detached signature
→ validate exact names and sizes
→ validate payload SHA-256
→ validate signature-file SHA-256
→ validate expected signing-key identity
→ cryptographically verify detached signature
→ perform platform-specific signing verification
→ install/replace
```

## Repeat verification at trust boundaries

Security-critical verification must be repeated where the update becomes irreversible.

### Windows

The main application verifies the downloaded release before invoking the updater. The separate updater independently verifies the payload and detached signature again immediately before extraction/replacement.

The updater must use its own pinned trust configuration; it must not accept a public key path or key identity supplied only by an untrusted update package.

### Android

The application verifies the release signature and SHA-256 before invoking the package installer, then also validates the APK package ID and canonical APK signing certificate. Android's own package-signature enforcement remains mandatory.

## Key rotation

Key rotation must be explicit. A new release key may be trusted only when introduced by an already trusted application/update path or another independently authenticated mechanism.

A remote manifest must never be able to replace the local trust anchor by itself.

## Starter tooling

The repository templates include OpenSSL-oriented starter scripts for detached signature creation and verification. Applications may use another cryptographic implementation, but the manifest metadata, trust model, and validation behavior must remain equivalent.
