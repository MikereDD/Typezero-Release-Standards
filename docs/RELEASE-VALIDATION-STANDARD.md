# Typezer∅ Release Validation Standard

## Principle

A successful build is not a validated release. Every Typezer∅ release must prove the complete path from source to installed result and record the evidence needed to reproduce the decision.

## Required validation chain

```text
source
→ version
→ build
→ package
→ checksum
→ detached signature
→ platform signing identity
→ manifest
→ Git tag/source commit correspondence
→ release publication
→ update discovery
→ valid update
→ restart or installer handoff
→ state preservation
→ no-update result
→ rollback/recovery
→ tampered payload rejection
→ tampered signature rejection
→ legacy updater protocol compatibility
```

## Validation record

Each application repository should create a record such as:

```text
docs/releases/RELEASE-VALIDATION-v<version>.md
```

At minimum record:

- application and version;
- channel;
- manifest schema version;
- updater protocol and minimum protocol;
- source repository;
- source commit;
- Git tag;
- release payload filename and size;
- payload SHA-256;
- detached signature filename, size, SHA-256, algorithm, and key ID;
- platform signing identity;
- build/package result;
- manifest verification result;
- source/tag/version correspondence result;
- publication location;
- update discovery result;
- upgrade path tested from at least one supported older version;
- no-update behavior when already current;
- state/settings preservation result;
- restart or Android installer handoff result;
- rollback/recovery result;
- intentionally corrupted payload rejection result;
- intentionally corrupted signature rejection result;
- incompatible legacy protocol rejection/result;
- known deviations or unresolved issues.

## Tamper tests

Tamper tests must use throwaway copies of release artifacts. Never modify the canonical published artifact merely to prove rejection.

Required tests include:

1. change at least one byte of the payload and confirm SHA-256/signature rejection;
2. change or replace the detached signature and confirm signature rejection;
3. provide an unapproved signing key and confirm trust rejection;
4. alter a critical manifest identity field and confirm rejection;
5. where platform signing applies, use a payload with a non-matching platform signing identity and confirm rejection.

## Windows-specific validation

Windows releases must additionally test:

- main app already exited before updater waits on the supplied process ID;
- replacement path resolves to the actual installed executable/application root;
- a versioned archive filename cannot redirect the restart target;
- required updater arguments are present before replacement begins;
- staged source hash equals the final installed target hash for critical replacement files;
- startup-health failure triggers bounded rollback and avoids retry loops.

## Android-specific validation

Android releases must additionally test:

- exact package-ID match;
- canonical signing-certificate match;
- update availability versus installation permission behavior;
- installer cancellation cleanup;
- same-version/no-update behavior;
- downgrade rejection;
- application data preservation during a normal signed upgrade.

## Reference cases

CouchLink's legacy-development-build → hardened-updater path and hardened signed-to-signed update path are the initial model examples. See `docs/COUCHLINK-REFERENCE-IMPLEMENTATION.md`.
