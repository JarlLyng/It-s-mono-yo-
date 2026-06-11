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

### 2. Run
```bash
pip install "pyjwt[crypto]"

export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_PRIVATE_KEY=~/.appstoreconnect/AuthKey_XXXXXX.p8
export ASC_VENDOR_NUMBER=1234567

python3 scripts/asc_downloads.py            # last 7 days
python3 scripts/asc_downloads.py --days 30
python3 scripts/asc_downloads.py --date 2026-06-10
```

Output shows units per day, a total, and breakdowns by product type and
country.

> Reports lag ~24–48h, so the most recent day or two may show `(no report)`.
> That is expected, not an error.
