# App Store entitlements (App Review)

This app requests **only the minimum entitlements** required for its functionality, in line with Apple’s guideline that apps should not use entitlements without matching functionality.

## Entitlements in use

| Entitlement | Purpose in the app |
|-------------|--------------------|
| **App Sandbox** (`com.apple.security.app-sandbox`) | Required for Mac App Store distribution. |
| **User-selected file read-write** (`com.apple.security.files.user-selected.read-write`) | The app lets the user pick WAV files and an output folder via **Open** / **Save** dialogs (`NSOpenPanel`). Read/write access is only used for those user-selected paths (and security-scoped bookmarks for the output folder). |

## Not used (and therefore not requested)

- **Network** – No outgoing network calls. “Check for Updates” only shows a message to check the App Store; it does not fetch version info from the internet.
- **Downloads folder** – File access is only via user-selected paths, not direct access to the Downloads folder.
- **Music folder** – Same as above; no direct access to the Music folder.

## Build settings

- `ENABLE_USER_SELECTED_FILES = readwrite` – Kept; matches the use of `NSOpenPanel` for input files and output directory.
- `ENABLE_FILE_ACCESS_DOWNLOADS_FOLDER` and `ENABLE_FILE_ACCESS_MUSIC_FOLDER` – **Removed** (not used).
- `ENABLE_OUTGOING_NETWORK_CONNECTIONS` – **Removed** (no network usage).

## For App Review notes

You can use this summary in **App Review notes** if needed:

*The app only uses (1) App Sandbox and (2) user-selected file read-write. All file access is through the system Open/Save dialogs; the app does not use network or any other folder access.*
