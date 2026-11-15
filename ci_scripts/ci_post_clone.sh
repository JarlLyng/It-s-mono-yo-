#!/bin/sh
# Xcode Cloud runs this immediately after cloning the repository.
#
# Writes the Sentry DSN (#114) into SampleDrumConverter/SentryDSN.txt, which is
# gitignored and bundled by the app's synchronized folder. The value comes from
# SENTRY_DSN, a secret environment variable on the Xcode Cloud workflow. The DSN
# is a public client credential (it ships inside the app), but it stays out of git.
#
# Without SENTRY_DSN no file is written, the app runs with crash reporting off,
# and builds and tests still pass. An archive without it is stopped by
# ci_pre_xcodebuild.sh, so a release can't ship without crash reports unnoticed.

set -e

DSN_FILE="${CI_PRIMARY_REPOSITORY_PATH:-..}/SampleDrumConverter/SentryDSN.txt"

if [ -n "${SENTRY_DSN}" ]; then
  printf '%s\n' "${SENTRY_DSN}" > "$DSN_FILE"
  echo "ci_post_clone: wrote SentryDSN.txt"
else
  rm -f "$DSN_FILE"
  echo "ci_post_clone: no SENTRY_DSN, so crash reporting is off in this build"
fi
