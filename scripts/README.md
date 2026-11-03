# scripts

Maintainer tooling for the website. Not part of the app.

- **`site_frame.py`** copies the pinned iamjarl-design release into
  `website/assets/`, checks every file against the tag's `sri.json`, and gives the guides,
  privacy and support the home's frame. `--check` reports pages that are out of date.
- **`date_sitemap.py`** dates each sitemap `<lastmod>` from git. The Pages deploy runs it.
- **`iamjarl-vendor.mjs`** is the design system's own vendoring tool, generated in its repo.
