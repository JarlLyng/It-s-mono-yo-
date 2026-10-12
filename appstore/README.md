# App Store screenshots

One folder per release, one file per slot. The Mac slot is `mac-hidpi`, 2880 × 1800.

- `raw/` holds window captures of the Release build in dark mode, 900 × 640 pt at 2×, with a
  60-file stereo pack dragged in as a folder.
- `manifest.json` sets the captions, the order and the look: dark ground, lime `#D0FF00`.
- `1.4.5/` is the set the manifest produces.

Compose with the hub's shared tool, run from a clone of the private hub:

```bash
.venv/bin/python tools/appstore_screenshots.py batch <this repo>/appstore/manifest.json
```

Captions are public copy, so they follow the house voice: no em-dashes, no hype, and pay-once
framing. When a new set replaces this one, delete the old folder. Git history keeps it.
