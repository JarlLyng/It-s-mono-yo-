# scripts

Maintainer tooling. Not part of the app.

## asc_downloads.py — App Store Connect downloads/sales

Pulls the daily Sales and Trends report (units/downloads) via the App Store
Connect API.

**No secrets live in this repo.** Credentials are read from environment
variables at runtime; the `.p8` private key stays on your machine and is
gitignored.

### 1. Create an API key
App Store Connect → **Users and Access → Integrations → App Store Connect API**
→ generate a key with the **Sales and Reports** role. Note the **Key ID** and
**Issuer ID**, and download the `AuthKey_XXXXXX.p8` (downloadable only once).
Find your **Vendor Number** under **Payments and Financial Reports**.

Keep the key outside the repo, e.g. `~/.appstoreconnect/AuthKey_XXXXXX.p8`.

### 2. Configure
Easiest: copy `.env.example` to `.env` (gitignored) in the repo root and fill
it in — the script auto-loads it. Or export the same variables in your shell.

```
ASC_KEY_ID=XXXXXXXXXX
ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ASC_VENDOR_NUMBER=1234567
ASC_PRIVATE_KEY=./AuthKey_XXXXXX.p8
```

### 3. Run

One-time setup of a local virtualenv (gitignored):
```bash
python3 -m venv .venv
.venv/bin/pip install "pyjwt[crypto]"
```

Then:
```bash
.venv/bin/python scripts/asc_downloads.py                      # last 7 days, all apps
.venv/bin/python scripts/asc_downloads.py --days 30 --app 6758866918
.venv/bin/python scripts/asc_downloads.py --all-time --app 6758866918
.venv/bin/python scripts/asc_downloads.py --date 2026-06-10
```

`--app` takes an Apple ID or a title substring. The Sales report covers the
whole vendor account, so without `--app` you get a per-app breakdown across
all your apps. `--all-time` sums monthly reports (kept 12 months) plus the
current month's daily reports.

Output shows units per day, a total, and breakdowns by product type and
country.

> Reports lag ~24–48h, so the most recent day or two may show `(no report)`.
> That is expected, not an error.
