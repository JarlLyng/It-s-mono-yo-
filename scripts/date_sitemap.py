#!/usr/bin/env python3
"""Date the sitemap from git: each page's <lastmod> is the date of the last commit to its file.

Never hand-written, and never the build date: Google stops trusting a lastmod that is always
the same or always today (#99, as walkful#191 and TrimrPix#98 do). The deploy runs this on its
checkout, so the served sitemap carries the dates and the committed one carries none. On main a
pull request is squash-merged, so a page's date is the day its change went live.

    python3 scripts/date_sitemap.py           # rewrite website/sitemap.xml in place (the deploy)
    python3 scripts/date_sitemap.py --print   # show the result, change nothing
"""
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
WEBSITE = ROOT / "website"
SITEMAP = WEBSITE / "sitemap.xml"
SITE = "https://itsmonoyo.iamjarl.com/"


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=True).stdout.strip()


def lastmod(loc):
    if not loc.startswith(SITE):
        raise SystemExit(f"The sitemap lists {loc}, which isn't on {SITE}.")
    path = loc[len(SITE):]
    if path == "" or path.endswith("/"):
        path += "index.html"
    source = (WEBSITE / path).relative_to(ROOT)
    if not (ROOT / source).is_file():
        raise SystemExit(f"The sitemap lists {loc}, but {source} does not exist.")
    date = git("log", "-1", "--format=%cs", "--", str(source))
    if not date:
        raise SystemExit(f"{source} has no commit to date it by.")
    return date


def main():
    # A shallow clone has one commit, so every page would get that commit's date.
    if git("rev-parse", "--is-shallow-repository") == "true":
        raise SystemExit("Shallow clone: every page would get the same date. Check out with fetch-depth: 0.")
    xml = re.sub(r"\s*<lastmod>[^<]*</lastmod>", "", SITEMAP.read_text(encoding="utf-8"))
    # Only a page's own <loc>: the home's <xhtml:link> alternate is left as it is.
    xml = re.sub(r"(\s*)<loc>([^<]+)</loc>",
                 lambda m: f"{m[1]}<loc>{m[2]}</loc>{m[1]}<lastmod>{lastmod(m[2])}</lastmod>", xml)
    if "--print" in sys.argv:
        print(xml)
    else:
        SITEMAP.write_text(xml, encoding="utf-8")
        print(f"Dated {xml.count('<lastmod>')} pages in {SITEMAP.relative_to(ROOT)}.")


if __name__ == "__main__":
    main()
