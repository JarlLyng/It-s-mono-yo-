# App Store screenshots

One folder per release, one file per slot. The Mac slot is `mac-hidpi`, 2880 × 1800.

- The raw captures are window captures of the Release build in dark mode, 900 × 640 pt at 2×,
  with a 60-file stereo pack dragged in as a folder. Two are in `raw/`; the list and the result
  are the site's own `website/assets/captures/tour-1-drop.png` and `tour-3-done.png`, so each
  capture lives in one place.
- `manifest.json` sets the captions, the order and the look: dark ground, lime `#D0FF00`.
- `1.4.5/` is the set the manifest produces.

The posters are composed from `manifest.json` with IAMJARL's shared screenshot tool, which
isn't part of this repo. The manifest records every input and caption, so the set can be
rebuilt from it.

Captions are public copy, so they follow the house voice: no em-dashes, no hype, and pay-once
framing. When a new set replaces this one, delete the old folder. Git history keeps it.
