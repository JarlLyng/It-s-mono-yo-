# Security Policy

## Reporting a vulnerability

If you've found a security issue in It's mono, yo!, please **don't open a public issue**. Email me directly:

**jarl@iamjarl.com**

Please include:
- A description of the vulnerability
- Steps to reproduce
- The affected version (Mac App Store version or commit SHA)
- Your contact info if you'd like credit when it's fixed

I'll respond within 7 days. For confirmed issues, I'll work on a patch and ship it as quickly as the App Store review process allows (typically 1–3 days for review, plus development time).

## Scope

In scope:
- It's mono, yo! macOS app code
- The marketing site at `itsmonoyo.iamjarl.com`

Out of scope:
- Apple platform vulnerabilities — report to Apple Product Security
- Issues in forks of this repo

## What It's mono, yo! does and doesn't handle

It's mono, yo! is a single-purpose audio batch converter with a deliberately small attack surface:

- **No backend.** No server, no database, no API endpoints.
- **No accounts.** No sign-up, no authentication, no password storage.
- **No internet.** The app does not require or use a network connection; audio files are converted entirely on-device.
- **No tracking.** No analytics in the app. The marketing website uses aggregate, cookieless analytics only.
- **Local file access only.** The app reads the audio files/folders you drop in and writes converted output (auto-renaming to avoid overwriting). Runs in the App Store sandbox.

If you find a way to break any of those guarantees, I want to know.

## Past advisories

None to date.
