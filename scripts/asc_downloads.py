#!/usr/bin/env python3
"""
Pull App Store Connect download / sales numbers from the command line.

NO secrets are stored in this repository. All credentials are read from
environment variables at runtime, and the private key stays on your machine
outside the repo.

Required environment variables:
    ASC_KEY_ID         Key ID of your App Store Connect API key
    ASC_ISSUER_ID      Issuer ID (Users and Access -> Integrations)
    ASC_PRIVATE_KEY    Path to the downloaded AuthKey_XXXXXX.p8 file
    ASC_VENDOR_NUMBER  Your vendor number (Payments and Financial Reports)

Set up the API key in App Store Connect:
    Users and Access -> Integrations -> App Store Connect API
    -> generate a key with the "Sales and Reports" access role.
    The .p8 file can be downloaded only once; keep it outside this repo
    (e.g. ~/.appstoreconnect/AuthKey_XXXXXX.p8).

Usage:
    pip install "pyjwt[crypto]"
    export ASC_KEY_ID=ABC123 ASC_ISSUER_ID=... \
           ASC_PRIVATE_KEY=~/.appstoreconnect/AuthKey_ABC123.p8 \
           ASC_VENDOR_NUMBER=1234567
    python3 scripts/asc_downloads.py             # last 7 days
    python3 scripts/asc_downloads.py --days 30
    python3 scripts/asc_downloads.py --date 2026-06-10

Note: App Store Connect sales reports lag ~24-48h. Days with no report yet
are skipped (the API returns 404 for them), so very recent days may be absent.
"""

import argparse
import datetime
import gzip
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

try:
    import jwt  # PyJWT (needs the [crypto] extra for ES256)
except ImportError:
    sys.exit('Missing dependency. Run:  pip install "pyjwt[crypto]"')

API_URL = "https://api.appstoreconnect.apple.com/v1/salesReports"


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        sys.exit(f"Missing required environment variable: {name}\n"
                 f"See the header of {os.path.basename(__file__)} for setup.")
    return value


def make_token(key_id: str, issuer_id: str, private_key_path: str) -> str:
    path = os.path.expanduser(private_key_path)
    try:
        with open(path, "r") as handle:
            private_key = handle.read()
    except OSError as error:
        sys.exit(f"Could not read private key at {path}: {error}")

    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 19 * 60,  # ASC tokens must live no longer than 20 minutes
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, private_key, algorithm="ES256",
                      headers={"kid": key_id, "typ": "JWT"})


def fetch_day(token: str, vendor: str, report_date: str):
    """Return the report TSV for a day, or None if no report exists yet."""
    params = {
        "filter[frequency]": "DAILY",
        "filter[reportType]": "SALES",
        "filter[reportSubType]": "SUMMARY",
        "filter[vendorNumber]": vendor,
        "filter[reportDate]": report_date,
        "filter[version]": "1_1",
    }
    request = urllib.request.Request(
        f"{API_URL}?{urllib.parse.urlencode(params)}",
        headers={"Authorization": f"Bearer {token}", "Accept": "application/a-gzip"},
    )
    try:
        with urllib.request.urlopen(request) as response:
            return gzip.decompress(response.read()).decode("utf-8")
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None  # no report for that date yet
        body = error.read().decode("utf-8", "replace")
        sys.exit(f"API error {error.code} for {report_date}: {body}")


def parse_rows(tsv: str):
    lines = tsv.splitlines()
    if len(lines) < 2:
        return []
    header = lines[0].split("\t")
    index = {name: i for i, name in enumerate(header)}
    rows = []
    for line in lines[1:]:
        cols = line.split("\t")
        if len(cols) < len(header):
            continue

        def col(name):
            return cols[index[name]] if name in index else ""

        try:
            units = int(col("Units") or 0)
        except ValueError:
            units = 0
        rows.append({
            "units": units,
            "type": col("Product Type Identifier"),
            "country": col("Country Code"),
            "title": col("Title"),
        })
    return rows


def main():
    parser = argparse.ArgumentParser(description="Pull App Store Connect daily sales/downloads.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--days", type=int, default=7, help="number of recent days to pull (default 7)")
    group.add_argument("--date", help="a single report date, YYYY-MM-DD")
    args = parser.parse_args()

    key_id = require_env("ASC_KEY_ID")
    issuer_id = require_env("ASC_ISSUER_ID")
    private_key = require_env("ASC_PRIVATE_KEY")
    vendor = require_env("ASC_VENDOR_NUMBER")

    token = make_token(key_id, issuer_id, private_key)

    if args.date:
        dates = [args.date]
    else:
        today = datetime.date.today()
        dates = [(today - datetime.timedelta(days=offset)).isoformat()
                 for offset in range(1, args.days + 1)]
        dates.reverse()

    grand_total = 0
    by_type: dict[str, int] = {}
    by_country: dict[str, int] = {}
    found_any = False

    print(f"{'Date':<12}{'Units':>8}")
    print("-" * 20)
    for report_date in dates:
        tsv = fetch_day(token, vendor, report_date)
        if tsv is None:
            print(f"{report_date:<12}{'(no report)':>8}")
            continue
        found_any = True
        rows = parse_rows(tsv)
        day_units = sum(r["units"] for r in rows)
        grand_total += day_units
        for r in rows:
            by_type[r["type"]] = by_type.get(r["type"], 0) + r["units"]
            by_country[r["country"]] = by_country.get(r["country"], 0) + r["units"]
        print(f"{report_date:<12}{day_units:>8}")

    if not found_any:
        print("\nNo reports available for the requested range yet (reports lag ~24-48h).")
        return

    print("-" * 20)
    print(f"{'TOTAL':<12}{grand_total:>8}")

    print("\nBy product type:")
    for ptype, units in sorted(by_type.items(), key=lambda kv: -kv[1]):
        print(f"  {ptype or '(blank)':<10}{units:>8}")

    print("\nTop countries:")
    for country, units in sorted(by_country.items(), key=lambda kv: -kv[1])[:10]:
        print(f"  {country or '(blank)':<10}{units:>8}")


if __name__ == "__main__":
    main()
