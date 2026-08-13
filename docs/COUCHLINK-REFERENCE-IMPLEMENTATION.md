# CouchLink Reference Implementation

## Role

CouchLink is the initial reference implementation and proving ground for the Typezer∅ Release Standards.

The purpose is not to make every Typezer∅ updater copy CouchLink's code. It is to use real CouchLink update failures and fixes to identify general requirements that other applications should not have to rediscover independently.

## Failure classes promoted into the standard

### 1. Multi-part prerelease comparison

Development versions may contain multiple numeric build components such as `dev.6.4`. The ecosystem comparator therefore parses numeric components instead of comparing strings.

### 2. Updater argument/protocol incompatibility

A newer updater contract introduced arguments that an older client did not supply. The standard now requires explicit updater protocol versions, minimum compatible client protocol, migration rules, and legacy-client tests.

### 3. Versioned filename versus installed target

A downloaded/versioned executable name must not become the authority for the installed target or restart path. The updater binds replacement to the known installation and actual installed executable.

### 4. Process-exit race

The main process may exit before the updater obtains or waits on it. "Process already exited" is a successful closed-state condition when identity/path checks are otherwise satisfied, not an automatic update failure.

### 5. Verification at the final trust boundary

Verification in the main application alone is not enough. The Windows updater independently rechecks payload SHA-256 and detached signature immediately before replacement.

### 6. Final target proof

After replacement, critical installed files are checked against the verified staged source so a successful copy operation is not assumed to prove the intended bytes reached the intended path.

### 7. Tamper rejection

Intentional corruption of payloads, signatures, and signing identities is a release test case rather than an assumed property.

## Model validation paths

The CouchLink audit established two useful model paths:

```text
legacy development build
→ newer hardened updater/release
→ compatibility behavior verified
```

and:

```text
hardened signed build
→ newer hardened signed build
→ checksum + detached signature + target verification
→ replacement
→ restart
→ state preserved
```

The exact CouchLink implementation may evolve. The requirements extracted here remain ecosystem rules unless deliberately revised in this standards repository.
