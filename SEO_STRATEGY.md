# SEO, ASO & GEO Strategy — It's mono, yo!

Site: https://itsmonoyo.iamjarl.com  
Mac App Store: https://apps.apple.com/app/its-mono-yo/id6758866918?mt=12  
GitHub: https://github.com/JarlLyng/It-s-mono-yo-  
Google Search Console: Connected  
Umami Analytics: Connected  
Last updated: 2026-04-15

---

## 1. Product positioning

Open-source macOS app til batch-konvertering af stereo WAV/AIFF til mono. Konfigurerbar bit-dybde (16/24/32-bit float), sample rate-konvertering og overwrite-beskyttelse. Bygget til hardware-samplere (SP-404, Digitakt, Model:Samples, Erica Synths Sample Drum, Eurorack). Betalt på Mac App Store, gratis at bygge fra kildekoden.

SEO positioning: **den specialiserede mono-konverter til hardware-samplere og musikproduktion** — differentierer fra generelle DAW'er (Logic, Audacity) og CLI-værktøjer (ffmpeg) via single-purpose design, drag-and-drop og hardware-sampler fokus.

---

## 2. Hvad der allerede er på plads

### Website technical SEO (done)

- [x] Statisk HTML, GitHub Pages (gh-pages branch)
- [x] `robots.txt` + `sitemap.xml` (9 URL'er)
- [x] SoftwareApplication + WebSite + BreadcrumbList + FAQPage JSON-LD på homepage
- [x] OG tags, Twitter cards, canonical URL på homepage og alle undersider
- [x] `meta name="keywords"` på homepage
- [x] Dark mode toggle
- [x] Google Search Console connected
- [x] Umami analytics

### Homepage (done)

- [x] Titel: "Convert Stereo WAV to Mono on Mac – It's mono, yo! | macOS Converter"
- [x] Stærk meta description med sampler-keywords
- [x] 6-item FAQ med FAQPage JSON-LD
- [x] Feature-sektion, hardware-kompatibilitets-sektion
- [x] App Store + GitHub CTA'er
- [x] Screenshot
- [x] GitHub star-badge

### SEO landing pages — 8 undersider (done)

| Side | Målsøgning |
|------|-------------|
| `convert-stereo-wav-to-mono-mac.html` | convert stereo wav to mono mac |
| `why-hardware-samplers-need-mono.html` | why hardware samplers need mono |
| `prepare-samples-erica-synths-sample-drum.html` | erica synths sample drum preparation |
| `prepare-samples-eurorack-samplers.html` | eurorack sample preparation |
| `prepare-samples-elektron-digitakt-mac.html` | digitakt sample preparation |
| `prepare-samples-roland-sp404.html` | sp404 sample preparation |
| `batch-convert-wav-to-mono-mac.html` | batch convert wav to mono mac |
| `privacy.html` | — |

### Off-site (done)

- [x] Product Hunt lanceret
- [x] Reddit r/modular
- [x] Reddit r/SP404
- [x] Reddit r/elektron
- [x] Elektronauts (Digitakt + Model:Samples)
- [x] Elektron Discord
- [x] GitHub README med topics og keywords

---

## 3. DU SKAL: Ret fejl i koden

Se `RETTELSER.md` i projektets rod. Opsummering:

1. **SoftwareApplication JSON-LD pris** → Offers mangler `price`-felt. Tilføj den faktiske pris (fx `"price": "1.99"`)
2. **AggregateRating** → Har kun 1 anmeldelse (`ratingCount: 1`). Fjern indtil der er 5+ anmeldelser, eller opdater med faktisk App Store-rating
3. **apple-itunes-app meta tag** → Mangler på ALLE sider. Tilføj `<meta name="apple-itunes-app" content="app-id=6758866918">` overalt
4. **JSON-LD på undersider** → Alle 8 undersider har NULV JSON-LD. Tilføj BreadcrumbList til alle + HowTo til guide-siderne + Article til "why hardware samplers need mono"
5. **Sitemap lastmod** → Opdater datostemplerne hvis siderne er ændret

---

## 4. ASO — Mac App Store Optimization

### Nuværende metadata (fra SEO_STRATEGY.md/APP_STORE_CONNECT)

**App name:** It's Mono, Yo!  
**Subtitle:** `Stereo to Mono in Seconds` (26 tegn)  
**Keywords (91 tegn):** `mono,stereo,WAV,AIFF,converter,audio,sample,drum,batch,16-bit,24-bit,sampler,downmix,music`

### DU SKAL: Udvid keyword-felt til 100 tegn

Nuværende bruger 91 tegn. Tilføj 9 tegn:

```
mono,stereo,WAV,AIFF,converter,audio,sample,drum,batch,16-bit,24-bit,sampler,downmix,music,SP-404
```

### DU SKAL: Overvej tysk lokalisering

Musikproduktion er internationalt engelsksproget, men tysk marked er stort for Eurorack/modularsynthesizere. Opret tysk storefront:

**Tysk (DE) keywords:**
```
audio converter,WAV,AIFF,mono,batch,sample rate,bit depth,hardware sampler,Eurorack,musikproduktion
```

### Screenshots-strategi

- Screenshot 1: "Drag and drop WAV files — batch conversion"
- Screenshot 2: "Configure bit depth and sample rate"
- Screenshot 3: "Perfect for SP-404, Digitakt, Eurorack"
- App Preview Video: 15 sek drag-and-drop → conversion → result

---

## 5. Keyword-strategi

### Tier 1 — Højeste relevans

- mono audio converter mac
- stereo to mono converter
- WAV to mono converter
- batch audio converter mac
- sample drum converter

### Tier 2 — Hardware-specifik (niche, high intent)

- SP-404 sample preparation
- Digitakt sample converter
- Eurorack sample preparation
- Erica Synths Sample Drum files
- Model:Samples mono conversion

### Tier 3 — Teknisk

- bit depth converter
- sample rate converter mac
- AIFF to mono
- ITU-R BS.775 downmix

### Tier 4 — Long-tail

- "convert stereo samples to mono for hardware sampler"
- "batch WAV conversion macOS"
- "open source audio converter macOS"

---

## 6. DU SKAL: Udvid cross-linking

### Footer-links til andre IAMJARL-projekter

Tilføj på alle sider:

- [iamjarl.com](https://iamjarl.com) — allerede til stede
- [Wean Nicotine](https://weannicotine.iamjarl.com) — relateret IAMJARL-projekt
- [WODrounds](https://wodrounds.iamjarl.com) — relateret IAMJARL-projekt
- [Made by Human](https://madebyhuman.iamjarl.com) — IAMJARL brand

### Intern cross-linking

Tilføj "Related guides"-links i bunden af hver landing page. Alle sampler-guides bør linke til hinanden:

- SP-404 → Digitakt → Erica Synths → Eurorack (ring-link)
- Alle → "Why Hardware Samplers Need Mono" og "Batch Convert" guide
- "Convert Stereo WAV" → alle sampler-specifikke sider

---

## 7. GEO — Generative Engine Optimization

### Hvad der er på plads

Homepage FAQ er velstruktureret (6 spørgsmål med direkte svar, FAQPage JSON-LD). Hardware-kompatibilitets-sektionen er god til AI-passage-ekstraktion.

### DU SKAL: Optimér undersider for AI-passage-ekstraktion

Undersiderne mangler den passage-struktur AI-motorer foretrækker:

1. **Direkte åbningssætning** — svar på søgeforespørgslen i første sætning
2. **Selvstændige sektioner** — forståelige uden kontekst
3. **Konkrete datapunkter** per sektion

**Target queries for AI-citation:**

- "Best way to convert stereo to mono on Mac" → `convert-stereo-wav-to-mono-mac.html`
- "How to prepare samples for Digitakt" → `prepare-samples-elektron-digitakt-mac.html`
- "Why convert samples to mono for hardware" → `why-hardware-samplers-need-mono.html`
- "Batch audio converter for Mac" → `batch-convert-wav-to-mono-mac.html`
- "SP-404 sample preparation" → `prepare-samples-roland-sp404.html`

### DU SKAL: Tilføj konkrete datapunkter

- "Mono samples reduce file size by 50% compared to stereo"
- "The Digitakt takes the left channel only — a proper mono mixdown preserves the full sound"
- "Supports WAV and AIFF with 16-bit, 24-bit, and 32-bit float output"
- "ITU-R BS.775 weighted downmix for multi-channel (surround) audio"
- "Open source — code available on GitHub"

---

## 8. Opgaver

Alle opgaver trackes som GitHub Issues: https://github.com/JarlLyng/It-s-mono-yo-/issues

Labels: `SEO`, `ASO`, `marketing`, `content`

---

## 9. Where to make noise

### Completed

- [x] Product Hunt
- [x] Reddit r/modular, r/SP404, r/elektron
- [x] Elektronauts (Digitakt, Model:Samples)
- [x] Elektron Discord

### Potential — se GitHub Issues for konkrete opgaver

- r/synthesizers, r/WeAreTheMusicMakers, r/macapps
- Hacker News (Show HN), LinkedIn
- Gearspace, ModularGrid, KVR Audio
- YouTube demo video

---

## 10. Monitoring

- **Google Search Console**: Ugentlig check — impressions, clicks, average position, crawl errors
- **Umami Analytics**: Sidevisninger, referral sources, top sider
- **Nøgletal**: Organisk trafik til hardware-specifikke sider, App Store downloads, GitHub stars/forks
