#!/usr/bin/env python3
"""Serve the design system from the site itself, and frame the pages (#92, #94).

The site loads iamjarl-design from its own origin, never from jsDelivr (#94,
PROJECT_STANDARDS §5): this script copies the files the site uses from the
release's GitHub tarball into website/assets/iamjarl-design@<release>/, checks
every one against the tag's own dist/sri.json, and points every page, the home
included, at that copy with the tag's hashes in `integrity`.

The home (website/index.html) is built on the design system's marketing kit. The
other pages keep their own words and Tailwind markup, and this script gives them
the same frame without the kit's marketing sections:

- the design system's files at the home's release, with SRI, in place of the
  old v1.11.1 and v1.18.1 ones, and the page held dark like the home;
- <ij-nav> in place of the old header, with a skip link;
- <ij-footer> in place of the old footer, keeping the links to every guide;
- the store fragment in place of the hand-made buttons, plus a midpage one
  under each guide's intro.

Each part sits between <!-- ij:… --> markers, so moving to a new release is a
rerun with a new RELEASE: a new folder and changed links, never a file edited in
place. --check reports the pages that are out of date and changes nothing.

    python3 scripts/site_frame.py            # write the pages
    python3 scripts/site_frame.py --check    # exit 1 if any page is stale
"""
import base64
import hashlib
import io
import json
import pathlib
import re
import shutil
import sys
import tarfile
import urllib.request

RELEASE = "v1.32.2"
TARBALL = f"https://github.com/JarlLyng/iamjarl-design/archive/refs/tags/{RELEASE}.tar.gz"
BASE = f"/assets/iamjarl-design@{RELEASE}"
# What the site loads from the design system. dist/ files are checked against the
# tag's sri.json; the badge and the font come with them as they are.
COPY = [
    "badges/mac-app-store-white-en-us.svg",
    "dist/components/ij-footer.js",
    "dist/components/ij-nav.js",
    "dist/css/tokens.css",
    "dist/fonts/jetbrains-mono.css",
    "dist/identity/its-mono-yo.css",
    "dist/kit/kit.css",
    "dist/kit/kit.js",
    "fonts/jetbrains-mono-latin-wght-normal.woff2",
]

SITE = pathlib.Path(__file__).resolve().parent.parent / "website"
GUIDES = [
    ("prepare-samples-erica-synths-sample-drum.html", "Erica Synths Sample Drum"),
    ("prepare-samples-elektron-digitakt-mac.html", "Elektron Digitakt"),
    ("prepare-samples-roland-sp404.html", "Roland SP-404"),
    ("prepare-samples-eurorack-samplers.html", "Eurorack samplers"),
    ("prepare-samples-elektron-octatrack-mac.html", "Elektron Octatrack"),
    ("prepare-samples-elektron-model-samples-mac.html", "Elektron Model:Samples"),
    ("prepare-samples-polyend-tracker-mac.html", "Polyend Tracker"),
    ("prepare-samples-akai-mpc-mac.html", "Akai MPC"),
    ("convert-stereo-wav-to-mono-mac.html", "Convert WAV to mono"),
    ("why-hardware-samplers-need-mono.html", "Why mono?"),
    ("batch-convert-wav-to-mono-mac.html", "Batch convert"),
]
PAGES = [g for g, _ in GUIDES] + ["privacy.html", "support.html"]


class Release:
    """The tag's files, read from its GitHub tarball (not from jsDelivr)."""

    def __init__(self):
        with urllib.request.urlopen(TARBALL) as r:
            data = r.read()
        self.files = {}
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
            for m in tar.getmembers():
                if m.isfile():
                    self.files[m.name.split("/", 1)[1]] = tar.extractfile(m).read()
        sri = json.loads(self.files["dist/sri.json"])
        assert sri["version"] == RELEASE.lstrip("v"), "sri.json is for another release"
        self.sri = sri["files"]

    def text(self, path):
        return self.files[path].decode()


REL = None


def fetch(path):
    return REL.text(path)


def copy_release(check):
    """Copy the files into the site, each dist/ file checked against sri.json.
    Returns True if the copy on disk is already exactly this."""
    dest = SITE / "assets" / f"iamjarl-design@{RELEASE}"
    current = True
    for path in COPY:
        body = REL.files[path]
        if path.startswith("dist/"):
            got = "sha384-" + base64.b64encode(hashlib.sha384(body).digest()).decode()
            assert got == REL.sri[path], f"{path}: hash mismatch with the tag's sri.json"
        target = dest / path
        if not target.exists() or target.read_bytes() != body:
            current = False
            if not check:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(body)
    for old in (SITE / "assets").glob("iamjarl-design@*"):
        if old.name != dest.name:
            current = False
            if not check:
                shutil.rmtree(old)
    return current


def pin(s):
    """Point every design-system link, script and image at the copy, with the tag's hash."""
    def tag(m):
        el, path = m.group(0), m.group(2)
        el = el.replace(m.group(1) + path, f"{BASE}/{path}")
        if path in REL.sri:
            el = re.sub(r'\s*crossorigin="[^"]*"', "", el)
            el = re.sub(r'integrity="[^"]*"', f'integrity="{REL.sri[path]}"', el)
        return el
    return re.sub(r'<(?:link|script|img)\b[^>]*?(?:href|src)="((?:https://cdn\.jsdelivr\.net/gh/jarllyng/iamjarl-design|/assets/iamjarl-design)@v[\d.]+/)([^"]+)"[^>]*>',
                  tag, s, flags=re.I)


def fragment(name, indent):
    body = re.sub(r"<!--.*?-->\n?", "", fetch(f"dist/store/{name}"), flags=re.S).strip()
    return "\n".join(indent + line for line in body.splitlines())


def build_blocks():
    css = "\n".join(
        f'    <link rel="stylesheet" href="{BASE}/{p}"\n      integrity="{REL.sri[p]}">'
        for p in ("dist/css/tokens.css", "dist/identity/its-mono-yo.css",
                  "dist/fonts/jetbrains-mono.css", "dist/kit/kit.css"))
    js = "\n".join(
        f'    <script type="module" src="{BASE}/{p}"\n      integrity="{REL.sri[p]}"></script>'
        for p in ("dist/components/ij-nav.js", "dist/components/ij-footer.js"))
    head = (f"<!-- ij:head {RELEASE} -->\n"
            "    <!-- The home's design-system files, served from this site with the tag's\n"
            "         hashes (#86, #92, #94). The identity sheet holds the page dark like the\n"
            "         home; html.dark turns on the Tailwind content's dark colours, whose\n"
            "         accent is already the lime. -->\n"
            '    <meta name="theme-color" content="#0D0F13">\n'
            f"{css}\n"
            '    <link rel="stylesheet" href="/assets/pages.css">\n'
            f"{js}\n    <!-- /ij:head -->")
    nav = ("<!-- ij:nav -->\n"
           '<a class="ij-skip" href="#main">Skip to content</a>\n'
           "<ij-nav>\n"
           '  <a slot="brand" href="/">It\'s mono, yo!</a>\n'
           '  <a slot="links" href="/#tour">How it works</a>\n'
           '  <a slot="links" href="/#where">Samplers</a>\n'
           '  <a slot="links" href="/#faq">FAQ</a>\n'
           '  <a slot="cta" href="https://apps.apple.com/app/id6758866918?pt=128512007&amp;ct=site&amp;mt=12"'
           ' data-umami-event="store-click" data-umami-event-store="mac-app-store"'
           ' data-umami-event-placement="nav" data-umami-event-locale="en">Download</a>\n'
           "</ij-nav>\n"
           "<!-- /ij:nav -->")
    cross = "\n".join("  " + l for l in fetch("dist/footers/its-mono-yo.html").splitlines() if l.startswith("<a "))
    links = "\n".join(f'  <a slot="links" href="/{href}">{label}</a>' for href, label in GUIDES)
    footer = ("<!-- ij:footer -->\n"
              '<ij-footer app="its-mono-yo">\n'
              '  <a slot="links" href="/">Home</a>\n'
              f"{links}\n"
              '  <a slot="links" href="/support.html">Support</a>\n'
              '  <a slot="links" href="/privacy.html">Privacy Policy</a>\n'
              '  <a slot="links" href="https://github.com/JarlLyng/It-s-mono-yo-">Source on GitHub</a>\n\n'
              f"{cross}\n"
              "</ij-footer>\n"
              "<!-- /ij:footer -->")
    mid = ("<!-- ij:store-midpage -->\n"
           '            <div class="my-8">\n'
           f'{fragment("its-mono-yo.en.midpage.white.html", "            ")}\n'
           "            </div>\n"
           "            <!-- /ij:store-midpage -->")
    end = ("<!-- ij:store-footer -->\n"
           f'{fragment("its-mono-yo.en.footer.white.html", "                ")}\n'
           "                <!-- /ij:store-footer -->")
    return head, nav, footer, mid, end


def marked(s, name, block):
    """Replace a marked block in place. Returns (text, found)."""
    pat = re.compile(rf"<!-- ij:{name}\b.*?<!-- /ij:{name} -->", re.S)
    if pat.search(s):
        return pat.sub(lambda _: block, s, count=1), True
    return s, False


def frame(page, s, blocks):
    head, nav, footer, mid, end = blocks

    s, ok = marked(s, "head", head)
    if not ok:
        # The old frame: the theme toggle, the v1.11.1 tokens and footer, the
        # footer's centring style, the self-hosted font preload, the v1.18.1 sheet.
        s = re.sub(r"\s*<script>(?:(?!</script>).)*toggleDarkMode(?:(?!</script>).)*</script>", "", s, flags=re.S)
        s = re.sub(r"\s*<!-- IAMJARL design system v1\.11\.1.*?</script>", "", s, flags=re.S)
        s = re.sub(r"\s*<style>\s*/\* The shared footer is built.*?</style>", "", s, flags=re.S)
        s = re.sub(r"\s*<!-- JetBrains Mono, the music family's display face.*?crossorigin>", "", s, flags=re.S)
        s = re.sub(r'\s*<link rel="stylesheet" href="https://cdn\.jsdelivr\.net/gh/JarlLyng/iamjarl-design@v1\.18\.1/[^>]*>', "", s)
        s = re.sub(r'\s*<meta name="theme-color"[^>]*>', "", s)
        s = s.replace("</head>", f"    {head}\n</head>", 1)
        s = re.sub(r"<html lang=\"en\">", '<html lang="en" class="dark">', s, count=1)

    s, ok = marked(s, "nav", nav)
    if not ok:
        s = re.sub(r"<body\b[^>]*>", '<body class="ij-page">', s, count=1)
        s = re.sub(r"<nav\b.*?</nav>", lambda _: nav, s, count=1, flags=re.S)
        # The old header was fixed and the content padded under it; ij-nav is sticky.
        s = re.sub(r'<main class="pt-(?:24|32) ', '<main id="main" class="pt-12 ', s, count=1)
        s = re.sub(r'<main class="(?![^"]*\bid=)', '<main id="main" class="', s, count=1)

    s, ok = marked(s, "footer", footer)
    if not ok:
        s = re.sub(r"<footer\b.*?</footer>", lambda _: footer, s, count=1, flags=re.S)

    s, ok = marked(s, "store-footer", end)
    if not ok and page in ("privacy.html", "support.html"):
        # No button of their own: the fragment closes the page's content.
        s = s.replace("</main>", '    <div class="container mx-auto px-6 max-w-3xl mt-12">\n                '
                      + end + "\n    </div>\n    </main>", 1)
    elif not ok:
        s = re.sub(r'<a href="https://apps\.apple\.com/[^"]*"[^>]*data-umami-event-placement="cta".*?</a>',
                   lambda _: end, s, count=1, flags=re.S)

    if page.startswith(("prepare-", "convert-", "batch-", "why-")):
        s, ok = marked(s, "store-midpage", mid)
        if not ok:
            # Under the guide's intro: the first paragraph after the h1.
            s = re.sub(r"(</h1>\s*<p\b.*?</p>)", lambda m: m.group(1) + "\n\n            " + mid, s, count=1, flags=re.S)
    return s


def main():
    global REL
    check = "--check" in sys.argv
    REL = Release()
    stale = [] if copy_release(check) else [f"assets/iamjarl-design@{RELEASE}"]
    blocks = build_blocks()
    for page in PAGES + ["index.html"]:
        path = SITE / page
        before = path.read_text()
        after = before if page == "index.html" else frame(page, before, blocks)
        after = pin(after)
        assert "cdn.jsdelivr.net" not in after, f"{page}: still loads from jsDelivr"
        if page != "index.html":
            for name in ("head", "nav", "footer"):
                assert f"<!-- ij:{name}" in after, f"{page}: no {name} block"
        if after != before:
            stale.append(page)
            if not check:
                path.write_text(after)
    print(("stale: " if check else "updated: ") + (", ".join(stale) or "none"))
    sys.exit(1 if check and stale else 0)


if __name__ == "__main__":
    main()
