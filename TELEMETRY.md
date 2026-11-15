# Telemetry

It's mono, yo! sends anonymous crash reports, diagnostics and one feature count to
[Sentry](https://sentry.io), stored in Sentry's EU region (#114). Nothing else leaves the Mac:
audio files are converted on the Mac and never uploaded. The code is
[`SampleDrumConverter/Telemetry.swift`](SampleDrumConverter/Telemetry.swift).

## What is sent

| Kind | When | Details |
|---|---|---|
| Crash report | the app crashes | where in the app's code it happened, the thread stacks, the app and macOS versions, the Mac model |
| App hang | the main thread is blocked | the same |
| MetricKit diagnostics | macOS delivers them | hangs, CPU and disk-write exceptions |
| Session | each launch | started, ended or crashed, for the crash-free rate |
| `conversion.finished` | a batch finishes with at least one file converted | one attribute, `format`: `wav` or `aiff` |

Every report carries the SDK version, the release, the environment, the macOS version, the Mac
model and the locale. Nothing more.

## The five rules

Anonymous is a recipe, not Sentry's default. Out of the box, sentry-cocoa sends a random installation
ID as the user, as every session's `did` and on every metric, plus a hash of the vendor ID. This app:

1. **Sends no identifier.** The user is `anonymous` on every install, set before any event or
   metric. `beforeSend` drops `contexts.app.device_app_hash` and `contexts.device.id`.
   `beforeSendMetric` keeps only an allowlist of attributes, so `user.id` never leaves. Sessions
   take their `did` from the SDK's `INSTALLATION` file, which the app pins to `anonymous` before the
   SDK starts. `sendDefaultPii` is off, and the SDK sends `infer_ip: never`. The Sentry organisation
   also stores no IP addresses and scrubs these fields server-side as a safety net.
2. **Stores nothing to measure.** No analytics ID and no "first seen" date. The pinned
   `INSTALLATION` file holds only the word `anonymous`.
3. **Sends only counts and coarse facts.** No file names, paths or audio. Breadcrumbs lose their
   data, and any message with a path. File I/O tracing and performance tracing are off.
4. **Watches nothing.** No screenshots, view hierarchy or session replay. sentry-cocoa offers none of
   them on macOS anyway.
5. **Says it plainly.** The [privacy policy](https://itsmonoyo.iamjarl.com/privacy.html),
   `PrivacyInfo.xcprivacy` (Crash Data and Performance Data for App Functionality, Product
   Interaction for Analytics, all not linked and not tracking) and the App Store label say the same
   as this file.

## Environments

`production` only for App Store builds. Debug builds report as `debug`, builds without an App Store
receipt as `development`, and builds with a sandbox receipt as `testflight`.

## For maintainers

- **The DSN** is not in git. Xcode Cloud reads the `SENTRY_DSN` secret on the workflow, and
  `ci_scripts/ci_post_clone.sh` writes it into `SampleDrumConverter/SentryDSN.txt` (gitignored),
  which the app bundles. `ci_scripts/ci_pre_xcodebuild.sh` stops an archive without it, so a release
  can't ship without crash reports unnoticed. Locally, put the DSN in that file or in the scheme's
  environment. Without one, the app runs with telemetry off.
- **dSYMs:** `ci_scripts/ci_post_xcodebuild.sh` uploads them after an archive with sentry-cli,
  pinned and checked by SHA-256. It needs the `SENTRY_AUTH_TOKEN` secret, and only warns without it.
- **After every sentry-cocoa upgrade,** repeat the envelope check: point a Debug build at a local
  server standing in for Sentry, and read one `session`, one `event` and one `trace_metric`
  envelope. No installation ID may appear, `user.id` must be `anonymous` or absent, and the event
  must have no `device_app_hash` and no device `id`. The `INSTALLATION` pin relies on SDK internals.
  If it stops working, set `enableAutoSessionTracking = false`.
- **A new count** needs a reason in an issue, a fixed set of values, and its attribute on the
  allowlist. Never a value from the user's files.
