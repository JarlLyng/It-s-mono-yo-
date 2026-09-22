# AGENTS.md — It's mono, yo!

Quick-start context for developers and AI assistants.

## What is It's mono, yo!?

An open-source macOS app for **batch converting stereo WAV and AIFF audio to mono**, with configurable bit depth, sample rate, and output format. Built for hardware samplers (Erica Synths Sample Drum, Elektron Digitakt, Roland SP-404, Eurorack). Native, lightweight, no internet required.

- **Developer:** Jarl Lyng / [IAMJARL](https://iamjarl.com)
- **Website:** [itsmonoyo.iamjarl.com](https://itsmonoyo.iamjarl.com)
- **App Store:** [apps.apple.com/app/its-mono-yo/id6758866918](https://apps.apple.com/app/its-mono-yo/id6758866918?mt=12)
- **License:** [MIT](LICENSE) — open source.
- **Price:** $0.99 USD one-time (no in-app purchases, no subscription, no ads)
- **Platform:** macOS 12.0+ (SwiftUI).

## Boundaries: work only in this repo

- Commit, push and open pull requests **only in this repo**. Never edit, commit to, push to or
  open a pull request in another IAMJARL repo, and that includes `iamjarl-design`.
- To ask another repo for something, **open an issue there**. Public repos get findings, never
  measured numbers. If it is strategic, or not safe in public, it goes to the hub instead.
- The one place outside this repo you write is this app's own folder in the private hub
  (`ItsMonoYo/`). Shared hub files (`PORTFOLIO.md`, the standards, `tools/`) are changed from inside
  the hub; if one needs changing, open an issue there.
- If a task seems to need a change in another repo, stop, open the issue, and carry on with what
  this repo can do.

## Strategy lives in the private hub

Target audience, positioning, pricing reasoning, SEO/ASO playbooks, and competitor analysis are **not** in this public repo — they're in the private [iamjarl-strategy](https://github.com/JarlLyng/iamjarl-strategy) hub (folder `ItsMonoYo/`). Before doing any audience/positioning/pricing/marketing-planning work, read that repo's `CONVENTIONS.md` and write results there, not here.

## App features (be precise — do not invent features that don't exist)

- **Batch conversion** — drag in unlimited WAV/AIFF files; **folder import** preserves structure recursively.
- **Configurable bit depth** — 16-bit (default), 24-bit, or 32-bit float; **output** WAV or AIFF.
- **Sample rate** — keep original or convert to 44.1 / 48 / 96 kHz.
- **Intelligent downmix** — proper stereo summing; multi-channel uses ITU-R BS.775 weighted coefficients.
- **Overwrite protection** — existing files auto-renamed, never replaced.
- Drag & drop; keyboard shortcut (⌘O to open files); VoiceOver / Reduce Motion / dark mode.
- In-app App Store review prompt after repeated successful conversions.

### Features that do NOT exist (common hallucination targets)
- No internet / cloud / accounts.
- No file count or size limits, but no audio *editing* — it converts, it doesn't edit.
- No subscription / IAP.

## Build & conventions
- SwiftUI, step-based conversion flow; Swift async/await with a bounded task group for parallel per-file conversion.
- Sandboxed App Store build with accessibility support.
- Privacy-first: no internet required; no tracking.
