# Channel and Rollback Policy

## Channel selection

Users explicitly choose Stable or Development. Applications may recommend Stable but must not silently enroll users in Development.

Switching from Development to Stable may imply a version decrease. The application must explain this and must not perform the downgrade automatically.

## Update eligibility

An update is eligible when:

- the manifest app ID and platform match the application;
- the selected channel matches;
- the target version is newer under the application's version comparator;
- the installed version satisfies the release's direct-update requirements;
- a compatible asset exists for the device or runtime.

## Windows rollback

Windows applications should retain one previous known-good release. Rollback may occur when:

- file replacement fails after backup;
- integrity checks on the installed result fail;
- the updated application cannot complete its startup health check.

Rollback must restore the complete prior application state, preserve user data, record the failure, and prevent an automatic retry loop.

## Android recovery

Normal Android updates do not include automatic downgrade rollback. Recovery should use a corrected APK with a higher version code and the same package ID and signing key.
