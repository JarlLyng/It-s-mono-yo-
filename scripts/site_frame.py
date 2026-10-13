#!/usr/bin/env python3
"""Give the site's guides, privacy and support the home's frame (#92).

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
rerun with a new RELEASE and new hashes. --check reports the pages that are
out of date and changes nothing.

    python3 scripts/site_frame.py            # write the pages
    python3 scripts/site_frame.py --check    # exit 1 if any page is stale
"""
import pathlib
import re
import sys
import urllib.request

RELEASE = "v1.29.1"
CDN = f"https://cdn.jsdelivr.net/gh/jarllyng/iamjarl-design@{RELEASE}"
# From the release notes, checked against the CDN. A wrong hash blocks the file
# with no visible cause, so copy them, never retype.
SRI = {
    "dist/css/tokens.css": "sha384-vobrBahZ7qeJ74LCQ/Q0e7jif8UTO/CGtv7PYdmZNRYk8A75O0IdZOyqtkfN/Yd6",
    "dist/identity/its-mono-yo.css": "sha384-PUrVeMj2eQeYFe91NzWY4AsWELe9L+3V3BJAB2D0Uo8DqJXptm600N6p3QxOsgPV",
    "dist/fonts/jetbrains-mono.css": "sha384-m5sTKiuLZVfgpzHrSArCLwS65xSR08vq68rr5sMbaXu7rLvz6swXTfxup+l9hQN4",
    "dist/kit/kit.css": "sha384-yQPt3mv7QSPG7IrfOYoxTrymnkZ8Ume5VDKVeBfBBYiHPTy1tDjneOG8WrwZW3hz",
    "dist/components/ij-nav.js": "sha384-x9Fn+y7Ku1i8bH8paRIcRE9kTRIkbDLhnD1WBw3YBMsYEpuqaTwwaUAfxUK/guk4",
    "dist/components/ij-footer.js": "sha384-AgojJpwfV8Vqm/RF8oRImW+9cKnbde+z+aP1Hq2KgThJ6fJz9h2FMwPs5s0tR/hK",
}

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


def fetch(path):
    with urllib.request.urlopen(f"{CDN}/{path}") as r:
        return r.read().decode()


def fragment(name, indent):
    body = re.sub(r"<!--.*?-->\n?", "", fetch(f"dist/store/{name}"), flags=re.S).strip()
    return "\n".join(indent + line for line in body.splitlines())


def build_blocks():
    css = "\n".join(
        f'    <link rel="stylesheet" href="{CDN}/{p}"\n      integrity="{SRI[p]}" crossorigin="anonymous">'
        for p in ("dist/css/tokens.css", "dist/identity/its-mono-yo.css",
                  "dist/fonts/jetbrains-mono.css", "dist/kit/kit.css"))
    js = "\n".join(
        f'    <script type="module" src="{CDN}/{p}"\n      integrity="{SRI[p]}" crossorigin="anonymous"></script>'
        for p in ("dist/components/ij-nav.js", "dist/components/ij-footer.js"))
    head = (f"<!-- ij:head {RELEASE} -->\n"
            "    <!-- The home's design-system files (#86, #92). The identity sheet holds the\n"
            "         page dark like the home; html.dark turns on the Tailwind content's dark\n"
            "         colours, whose accent is already the lime. -->\n"
            '    <meta name="theme-color" content="#0D0F13">\n'
            f"{css}\n{js}\n    <!-- /ij:head -->")
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
    check = "--check" in sys.argv
    blocks = build_blocks()
    stale = []
    for page in PAGES:
        path = SITE / page
        before = path.read_text()
        after = frame(page, before, blocks)
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
