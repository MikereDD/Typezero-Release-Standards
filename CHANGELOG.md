# Changelog

All notable changes to the Typezer∅ Release Standards are documented here.

The project is currently pre-v1.0. Until the first stable standards release, breaking improvements may land when they are required to close verified updater failure modes.

## Unreleased

### Changed

- Hardened the shared release model using CouchLink as the initial reference implementation and proving ground.
- Advanced the release manifest to schema revision 2.
- Added explicit updater protocol and minimum compatible updater protocol fields.
- Defined exact numeric comparison for multi-part Development versions such as `1.3-dev.6.4`.
- Added detached release-signature metadata, signing-key identity, and canonical public-key fingerprint rules.
- Added source repository, Git tag, and source commit correspondence.
- Hardened Windows staging, path validation, process-exit handling, target binding, repeated verification, restart validation, and rollback requirements.
- Hardened Android release-origin, package-ID, signing-certificate, protocol, downgrade, installer, and cleanup requirements.
- Added release validation records, tamper-rejection cases, and legacy-updater compatibility tests.
- Added starter detached-signing and verification tooling to both platform templates.
