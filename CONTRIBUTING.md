# Contributing

Changes to the shared schema or mandatory security rules should be reviewed against both platform standards.

When modifying the manifest schema:

1. Update the schema documentation.
2. Update both example manifests.
3. Update both templates when affected.
4. Preserve backward compatibility or increment `schemaVersion`.
5. Never weaken checksum, package identity, signing, or downgrade protections merely for convenience.
