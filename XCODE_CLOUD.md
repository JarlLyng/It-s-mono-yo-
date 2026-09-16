# Xcode Cloud

For **maintainers**. Xcode Cloud is not under the Product menu; see below.

---

## Where the configuration actually lives

**Workflows live server-side in App Store Connect, not in this repo.** Nothing in git
controls them. `ci_scripts/` and this file are the only traces Xcode Cloud leaves here, and
their presence says nothing about whether a workflow currently exists or which branch it
builds. A branch trigger (for example "build when `release` is updated") is configured in
App Store Connect or Xcode, never in the repository.

Two places to look:

- **App Store Connect** → Xcode Cloud. Use this to check whether the product exists at all.
- **Xcode** → Report Navigator (**⌘9**) → **Cloud** / **Integrations**. Use this to create or
  edit workflows. If you have never connected the app, this shows a getting-started guide.

---

## Requirements

### 1. Apple account and role
- Signed in with an Apple ID in the **Apple Developer Program** (Xcode → Settings ⌘, → Accounts).
- A role that can create apps in App Store Connect (Account Holder, Admin or App Manager).
- Note the Xcode Cloud REST API needs Admin or App Manager rights; a Sales and Reports or
  Metadata key gets `403 FORBIDDEN` on `/v1/ciProducts`.

### 2. Git remote
- Xcode Cloud builds from a Git repository with a remote. Source Control navigator (**⌘2**)
  should show `origin` → `https://github.com/JarlLyng/It-s-mono-yo-.git`.

### 3. Shared scheme
- The shared scheme is **`SampleDrumConverter`**, not "It's mono, yo!". The project was renamed
  but the scheme never was. **Pick `SampleDrumConverter` when the workflow asks for a scheme**,
  or the build fails.
- It is committed at `It's mono, yo!.xcodeproj/xcshareddata/xcschemes/SampleDrumConverter.xcscheme`,
  which is what makes it visible to Xcode Cloud. Verify with:
  `xcodebuild -list -project "It's mono, yo!.xcodeproj"`.

---

## Release convention

Releases are cut by pushing to the **`release`** branch, matching the other apps in the
portfolio. `main` is the development branch and should not trigger release builds.

## Branch trigger

Configure the workflow's start condition on **`release`**, then bump `MARKETING_VERSION` and
`CURRENT_PROJECT_VERSION`, merge to `main`, and push `main:release`.

---

**Reference:** [Xcode Cloud documentation](https://developer.apple.com/documentation/Xcode/Xcode-Cloud/)
