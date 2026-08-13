# Typezer∅ Version Comparison Standard

## Purpose

Every Typezer∅ updater must make the same decision about whether one application version is newer than another. String comparison is forbidden because it misorders numeric components such as `dev.10` and `dev.9` and cannot safely handle multi-part development builds such as `dev.6.4`.

## Canonical version forms

Stable:

```text
<numeric-core>
```

Development:

```text
<numeric-core>-dev.<numeric-build>[.<numeric-build>...]
```

Examples:

```text
1.0
1.0.1
1.3-dev.6
1.3-dev.6.4
2.7-dev.10.9.1
```

Each numeric component is a non-negative base-10 integer. Components are compared numerically.

## Comparison algorithm

1. Parse the numeric core on `.` boundaries.
2. Compare numeric-core components left to right as integers.
3. When one numeric core has fewer components, missing trailing components are treated as zero.
4. If numeric cores differ, the greater core is newer.
5. If numeric cores are equal and one version is Stable while the other is Development, Stable is newer than Development for ordering purposes.
6. If both are Stable, they are equal after normalized numeric-core comparison.
7. If both are Development, compare each `dev` numeric component left to right as an integer.
8. Missing trailing development components are treated as zero.

Channel eligibility is checked separately. A Development installation must not silently cross to Stable, and Stable must not silently cross to Development merely because ordering would otherwise call one version newer.

## Required examples

| Installed | Candidate | Ordering result |
|---|---|---|
| `1.3-dev.6.3` | `1.3-dev.6.4` | candidate newer |
| `1.3-dev.6.4` | `1.3-dev.6.3` | candidate older |
| `1.3-dev.9` | `1.3-dev.10` | candidate newer |
| `1.3-dev.6.4` | `1.3-dev.6.4` | equal / no update |
| `1.3-dev.6.4` | `1.3` | Stable orders newer, but channel policy still applies |
| `1.3` | `1.3-dev.99` | candidate older by release ordering and channel policy still applies |
| `1.9` | `1.10` | candidate newer |
| `2.7-dev.10.9` | `2.7-dev.10.9.1` | candidate newer |

Machine-readable vectors are in `examples/version-comparison-vectors.json`.

## Invalid input

An updater must reject malformed versions instead of guessing. A parsing failure is an update-check failure, not permission to fall back to lexical comparison.
