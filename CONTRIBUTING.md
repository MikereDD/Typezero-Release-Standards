# Contributing

Changes to the shared schema, updater protocol, version comparator, signing model, or mandatory security rules must be reviewed against both platform standards.

When modifying the manifest schema:

1. Update the schema documentation.
2. Update both example manifests.
3. Update both platform templates when affected.
4. Preserve backward compatibility or increment `schemaVersion`.
5. If an updater must understand a new required field, argument, or behavior, increment the updater protocol and document the compatibility transition.
6. Add or update compatibility and regression test cases.
7. Never weaken checksum, source identity, package identity, signing, path validation, downgrade, or rollback protections merely for convenience.

A failure discovered in a reference implementation should be converted into a general rule or regression case when it can affect other Typezer∅ applications.
