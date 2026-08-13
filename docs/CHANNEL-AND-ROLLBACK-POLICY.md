# Channel and Rollback Policy

## Channel selection

Users explicitly choose Stable or Development. Applications may recommend Stable but must not silently enroll users in Development or move Development users to Stable.

A UI may call the Development channel "Test", but the canonical manifest value remains `development`.

Switching channels may imply a version decrease. The application must explain this and must not perform the downgrade automatically.

## Update eligibility

A normal update is eligible only when:

- manifest app ID and platform match;
- architecture is compatible where applicable;
- selected channel matches;
- target version is newer under the Typezer∅ numeric version comparator;
- installed version satisfies the release's `minimumVersion` direct-update requirement;
- local updater protocol satisfies `minimumUpdaterProtocolVersion`;
- an approved asset exists for the device/runtime;
- manifest and asset origins are approved;
- required release/platform signing identities are trusted.

If the target version equals the installed version, the result is no update. Automatic reinstall is not permitted.

If the target is older, it is a downgrade and not a normal update.

## Windows rollback

Windows applications retain one previous known-good release by default. Rollback may occur when:

- file replacement fails after backup;
- final installed-target verification fails;
- integrity checks on the installed result fail;
- the updated application cannot complete its transaction-scoped startup health check.

Rollback must restore the complete prior application state, preserve user data, record the failure, and prevent an automatic retry loop.

Rollback uses the locally preserved known-good version. It does not authorize downloading an arbitrary older remote release.

## Android recovery

Normal Android updates do not include automatic downgrade rollback. Recovery should use a corrected APK with a higher version code and the same package ID and signing key.

If a manual downgrade/recovery flow is ever supported, it must be explicitly documented, preserve platform signing rules, and warn about application-data compatibility.
