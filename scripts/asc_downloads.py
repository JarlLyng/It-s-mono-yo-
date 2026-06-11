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


def load_env_file() -> None:
    """Populate os.environ from a local .env (gitignored), if present.

    Looks in the current directory and in the repo root (the script's parent
    folder). Existing real environment variables always win.
    """
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for candidate in (os.path.join(os.getcwd(), ".env"), os.path.join(repo_root, ".env")):
        if not os.path.exists(candidate):
            continue
        with open(candidate) as handle:
            for line in handle:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, _, value = line.partition("=")
                os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def autodetect_private_key():
    """Return the path to a lone .p8 in the repo root, if exactly one exists."""
    import glob
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    matches = glob.glob(os.path.join(repo_root, "*.p8"))
    return matches[0] if len(matches) == 1 else None


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


def fetch_report(token: str, vendor: str, report_date: str, frequency: str = "DAILY"):
    """Return the report TSV for a date, or None if no report exists yet."""
    params = {
        "filter[frequency]": frequency,
        "filter[reportType]": "SALES",
        "filter[reportSubType]": "SUMMARY",
        "filter[vendorNumber]": vendor,
        "filter[reportDate]": report_date,
        # filter[version] is omitted so the API uses the latest version for each
        # report type (it differs: daily SALES is 1_1, monthly is 1_0).
    }
    request = urllib.request.Request(
        f"{API_URL}?{urllib.parse.urlencode(params)}",
        headers={"Authorization": f"Bearer {token}", "Accept": "application/a-gzip"},
    )
    try:
        with urllib.request.urlopen(request) as response:
            return gzip.decompress(response.read()).decode("utf-8")
    except urllib.error.HTTPError as error:
        # 404: no report for that date yet. 410: aged out (daily kept 365 days,
        # monthly 12 months). Both just mean "nothing here" — skip.
        if error.code in (404, 410):
            return None
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
            "apple_id": col("Apple Identifier"),
        })
    return rows


def main():
    parser = argparse.ArgumentParser(description="Pull App Store Connect daily sales/downloads.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--days", type=int, default=7, help="number of recent days to pull (default 7)")
    group.add_argument("--date", help="a single report date, YYYY-MM-DD")
    group.add_argument("--all-time", action="store_true", dest="all_time",
                       help="total since release: monthly reports for completed months "
                            "plus daily reports for the current month")
    parser.add_argument("--app", help="filter to one app by Apple ID or a case-insensitive title substring "
                                      "(the report covers your whole vendor account)")
    args = parser.parse_args()

    load_env_file()
    key_id = require_env("ASC_KEY_ID")
    issuer_id = require_env("ASC_ISSUER_ID")
    private_key = os.environ.get("ASC_PRIVATE_KEY") or autodetect_private_key()
    if not private_key:
        sys.exit("Set ASC_PRIVATE_KEY to your .p8 path, or place a single .p8 in the repo root.")
    vendor = require_env("ASC_VENDOR_NUMBER")

    token = make_token(key_id, issuer_id, private_key)

    # Build the list of (frequency, report_date) keys to fetch.
    today = datetime.date.today()
    keys: list[tuple[str, str]] = []
    if args.all_time:
        # Completed months: monthly reports are kept for 12 months
        # (months before release simply return 404/410 and are skipped).
        year, month = today.year, today.month
        for _ in range(12):
            month -= 1
            if month == 0:
                year, month = year - 1, 12
            keys.append(("MONTHLY", f"{year:04d}-{month:02d}"))
        keys.reverse()
        # Current (incomplete) month: daily reports day 1..today.
        for day in range(1, today.day + 1):
            keys.append(("DAILY", datetime.date(today.year, today.month, day).isoformat()))
    elif args.date:
        keys = [("DAILY", args.date)]
    else:
        days = [(today - datetime.timedelta(days=offset)).isoformat()
                for offset in range(1, args.days + 1)]
        days.reverse()
        keys = [("DAILY", d) for d in days]

    def matches(row):
        if not args.app:
            return True
        needle = args.app.lower()
        return needle == row["apple_id"].lower() or needle in row["title"].lower()

    per_period = []       # (label, units-after-filter or None)
    by_type: dict[str, int] = {}
    by_country: dict[str, int] = {}
    by_app: dict[str, int] = {}
    grand_total = 0
    found_any = False

    for frequency, report_date in keys:
        tsv = fetch_report(token, vendor, report_date, frequency)
        if tsv is None:
            per_period.append((report_date, None))
            continue
        found_any = True
        rows = [r for r in parse_rows(tsv) if matches(r)]
        period_units = sum(r["units"] for r in rows)
        grand_total += period_units
        for r in rows:
            by_type[r["type"]] = by_type.get(r["type"], 0) + r["units"]
            by_country[r["country"]] = by_country.get(r["country"], 0) + r["units"]
            by_app[r["title"]] = by_app.get(r["title"], 0) + r["units"]
        per_period.append((report_date, period_units))

    if not found_any:
        print("No reports available for the requested range yet (reports lag ~24-48h).")
        return

    scope = f"app filter: {args.app}" if args.app else "whole vendor account (all apps)"
    print(f"Scope: {scope}\n")
    print(f"{'Period':<12}{'Units':>8}")
    print("-" * 20)
    for label, units in per_period:
        print(f"{label:<12}{('(no report)' if units is None else units):>8}")
    print("-" * 20)
    print(f"{'TOTAL':<12}{grand_total:>8}")

    if not args.app:
        print("\nBy app:")
        for title, units in sorted(by_app.items(), key=lambda kv: -kv[1]):
            print(f"  {(title or '(blank)')[:34]:<36}{units:>6}")

    print("\nBy product type:")
    for ptype, units in sorted(by_type.items(), key=lambda kv: -kv[1]):
        print(f"  {ptype or '(blank)':<10}{units:>8}")

    print("\nTop countries:")
    for country, units in sorted(by_country.items(), key=lambda kv: -kv[1])[:10]:
        print(f"  {country or '(blank)':<10}{units:>8}")


if __name__ == "__main__":
    main()
