# Rettelser — It's mono, yo!

Fundet ved gennemgang af website (gh-pages branch) og SEO_STRATEGY.md d. 15. april 2026.

---

## 1. SoftwareApplication JSON-LD: manglende pris

**Fil:** `index.html` (gh-pages branch)

Offers-objektet har `priceCurrency: "USD"` men INTET `price`-felt. Appen er betalt i Mac App Store. Google kræver et `price`-felt for at vise Rich Results. Tilføj fx:

```json
"price": "1.99",
"priceCurrency": "USD"
```

(Sæt til den faktiske pris i USD.)

---

## 2. AggregateRating med 1 anmeldelse

**Fil:** `index.html` (gh-pages branch)

```json
"aggregateRating": {
  "@type": "AggregateRating",
  "ratingValue": "5",
  "ratingCount": "1",
  "bestRating": "5"
}
```

Google fraråder self-declared ratings og kan give en Rich Results-advarsel eller ignorere dette helt. Med kun 1 anmeldelse er det bedre at fjerne AggregateRating indtil der er nok anmeldelser til at det er troværdigt (5+). Alternativt: opdater med den faktiske App Store-rating.

---

## 3. Ingen apple-itunes-app meta tag

**Fil:** Alle HTML-filer (gh-pages branch)

Ingen sider har `<meta name="apple-itunes-app" content="app-id=6758866918">`. Denne meta tag viser et Smart App Banner i Safari. Tilføj til alle sider:

```html
<meta name="apple-itunes-app" content="app-id=6758866918">
```

---

## 4. Ingen JSON-LD på undersider

**Filer:** Alle 8 undersider (gh-pages branch)

Kun homepage har JSON-LD. Alle undersider mangler det helt:
- `convert-stereo-wav-to-mono-mac.html` — bør have HowTo + BreadcrumbList
- `why-hardware-samplers-need-mono.html` — bør have Article + BreadcrumbList
- `prepare-samples-erica-synths-sample-drum.html` — bør have HowTo + BreadcrumbList
- `prepare-samples-eurorack-samplers.html` — bør have HowTo + BreadcrumbList
- `prepare-samples-elektron-digitakt-mac.html` — bør have HowTo + BreadcrumbList
- `prepare-samples-roland-sp404.html` — bør have HowTo + BreadcrumbList
- `batch-convert-wav-to-mono-mac.html` — bør have HowTo + BreadcrumbList
- `privacy.html` — bør have BreadcrumbList

SEO-strategien hævder at "Article JSON-LD with author on all article pages" og "BreadcrumbList on all pages" — dette er forkert.

---

## 5. SEO-strategien nævner ikke alle sider

SEO_STRATEGY.md nævner 6 indholdssider, men websitet har 8 HTML-filer (+ index + privacy). Manglende i strategien:
- `prepare-samples-elektron-digitakt-mac.html`
- `prepare-samples-roland-sp404.html`

Disse to er til stede i sitemap.xml og på websitet, men ikke nævnt i strategiens sideoversigt.

---

## 6. Sitemap mangler lastmod-opdatering

Sitemap.xml har `lastmod: 2026-03-07` for de ældste sider og `2026-04-02` for de nyeste. Hvis siderne er blevet opdateret, bør lastmod afspejle dette.
