# Typezer∅ Updater Protocol Compatibility

## Purpose

Updater compatibility is an explicit release property. This requirement exists because adding a new required updater argument, field, or behavior can break a valid update path even when both the old and new application versions understand the same basic manifest.

## Manifest fields

Every published manifest declares:

```json
"updaterProtocolVersion": 2,
"minimumUpdaterProtocolVersion": 1
```

- `updaterProtocolVersion` is the protocol revision implemented by the target release/update contract.
- `minimumUpdaterProtocolVersion` is the oldest updater protocol allowed to consume that release safely.

`minimumUpdaterProtocolVersion` must never exceed `updaterProtocolVersion`.

## Client behavior

Each updater implementation must have a locally compiled or otherwise trusted protocol version.

Before downloading or installing a payload:

1. validate the manifest schema revision;
2. read `minimumUpdaterProtocolVersion`;
3. compare it with the local updater protocol version;
4. stop safely if the local updater is too old;
5. present an approved bootstrap, full-installer, or application-upgrade path rather than attempting incompatible invocation.

An updater must not infer compatibility because a field happens to deserialize successfully.

## Changing the updater contract

A protocol increment is required when a change makes an older updater unsafe or unable to complete the update, including:

- adding a required command-line argument;
- changing argument meaning or path semantics;
- adding a required verification step that old updaters cannot perform;
- changing staging or replacement assumptions;
- changing restart/health-check handshake behavior;
- requiring a new signing algorithm or trust-anchor mechanism.

A protocol increment is not required for an optional field that older clients may safely ignore and whose absence preserves the previous behavior.

## Migration rule

When introducing a protocol-breaking feature, one of these must be true:

- the new field/argument remains optional during a migration window; or
- the release raises `minimumUpdaterProtocolVersion` and provides a supported path for older clients.

The release must never advertise itself as directly compatible with a client that cannot perform the required update transaction.

## Compatibility tests

Every protocol increment must test at least:

- current application/current updater → current release;
- previous supported updater protocol → current release;
- updater below the minimum protocol → clean rejection with a useful recovery path;
- missing newly introduced arguments → deterministic failure before replacement;
- extra optional fields → safe behavior for clients that are documented to ignore them.

CouchLink's older-development-build to hardened-updater tests are the initial model for this requirement.
