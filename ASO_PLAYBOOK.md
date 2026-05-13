# ASO Playbook — It's mono, yo!

App Store Optimization playbook with current state, recommended changes, and a copy-paste action list for App Store Connect.

**Last updated:** 2026-05-13

---

## 1. Current Metadata Audit

### Title (30/30 chars max)
```
It's Mono, Yo! – Audio Tool
```
**Status:** OK. Uses generic "Audio Tool" suffix which is fine for discoverability, but could be more specific. Apple weights words in the title VERY heavily for ranking.

**Recommended A/B test variant:**
```
It's Mono, Yo! – WAV to Mono
```
This puts the highest-intent keyword ("WAV to Mono") directly in the title. Tests show title keyword changes can swing search rank by 5-20 positions.

### Subtitle (27/30 chars used)
```
Stereo to Mono in Seconds
```
**Status:** Catchy but missing keywords. The subtitle is the SECOND most weighted field for ranking.

**Recommended A/B test variant:**
```
Batch Mono Converter for Mac
```
This adds "Batch", "Converter", "Mac" — all high-intent keywords not in the title.

### Keywords field (91/100 chars used)
**Current:**
```
mono,stereo,WAV,AIFF,converter,audio,sample,drum,batch,16-bit,24-bit,sampler,downmix,music
```

**Recommended (100/100 chars):**
```
mono,WAV,AIFF,converter,sample,drum,batch,16bit,24bit,sampler,downmix,SP404,digitakt,eurorack
```

**What changed:**
- Removed `stereo` (already implied by "mono converter" — Apple does plural/related matching)
- Removed `audio`, `music` (too broad to compete on)
- Removed `16-bit`/`24-bit` hyphens (Apple normalizes)
- Added `SP404`, `digitakt`, `eurorack` (high-intent niche keywords)
- All terms are searched-for and have very low competition

### Promotional Text (170 chars limit)
**Current:**
```
Version 1.2: Now with AIFF support, configurable bit depth (16/24/32-bit), sample rate conversion, and no file limits.
```
**Status:** Good for version announcement. Promotional text changes don't require app review — you can update anytime.

---

## 2. Product Page Optimization (Free A/B Testing)

Apple lets you test up to 3 page variants for free, 90 days each. Set up in App Store Connect → "Product Page Optimization".

### Test #1 — Screenshot Set (highest impact)

**Original (Control):**
- Current screenshots from v1.0.x

**Variant A — Workflow-focused:**
- Screenshot 1: "Drag any WAV file in"
- Screenshot 2: "Pick your output format"
- Screenshot 3: "Get clean mono files"
- Screenshot 4: SP-404 / Digitakt / Eurorack context

**Variant B — Feature-focused:**
- Screenshot 1: Output settings UI close-up
- Screenshot 2: Batch list with 50+ files
- Screenshot 3: "16/24/32-bit float"
- Screenshot 4: Compatible hardware grid

**Hypothesis:** Workflow-focused (A) will convert better because it shows the user's job-to-be-done. Feature-focused (B) works better for sophisticated users.

### Test #2 — App Icon (after screenshots)

Once you have new screenshots, test:
- **Original:** Wave bars on black
- **Variant A:** Same wave bars + small "M" letter (mono indicator)
- **Variant B:** Different color scheme (matches new purple primary)

### Test #3 — App Preview Video (when made)

Test having a video vs. no video. Apps with App Preview Videos typically convert 25-30% better.

---

## 3. Custom Product Pages

Create up to 35 different App Store pages, each with its own URL. Perfect for targeted traffic from Reddit, blogs, etc.

### Custom Page 1 — "Eurorack Modular"
**URL:** Auto-generated, ends in `?pt=...&ct=eurorack`
**Use for:** Links from r/modular, ModularGrid, Eurorack-related blogs

**Promotional Text:**
```
Built for Eurorack samplers. Batch convert stereo samples to mono for Assimil8or, Sample Drum, and other modular samplers.
```

**Screenshots:** Show Eurorack-specific use cases — drag in samples, output to USB stick, etc.

### Custom Page 2 — "Elektron Workflow"
**URL:** Ends in `?pt=...&ct=elektron`
**Use for:** Links from Elektronauts, r/elektron, Elektron Discord

**Promotional Text:**
```
Prep your sample library for Digitakt, Model:Samples, and Octatrack. Proper stereo summing instead of left-channel-only.
```

### Custom Page 3 — "Roland SP-404 Beat Makers"
**URL:** Ends in `?pt=...&ct=sp404`
**Use for:** Links from r/SP404, lo-fi communities

**Promotional Text:**
```
Double your SP-404 sample capacity with mono. Drag a sample pack, hit convert, transfer to your SD card. Done.
```

### How to set up
1. App Store Connect → Your app → Custom Product Pages
2. Click "+", give it a name
3. Upload 3-10 alternative screenshots (or reuse existing)
4. Customize promotional text
5. Save → you get a URL to use in your Reddit posts, etc.

---

## 4. Apple Search Ads — Keyword Bid List

For a niche like ours, Apple Search Ads can be VERY cost-efficient. Most niche keywords cost $0.20-0.80 per tap (not install).

### Budget recommendation: $1-2/day to start ($30-60/month)

### Tier 1 keywords (high intent, low competition)
```
stereo to mono           ~$0.30-0.50  (small bid)
wav mono converter       ~$0.40-0.60
mono audio converter     ~$0.50-0.80
sample drum converter    ~$0.20-0.40  (super niche)
```

### Tier 2 keywords (hardware-specific)
```
sp404 samples            ~$0.30-0.50
digitakt sample prep     ~$0.20-0.40
eurorack sampler         ~$0.40-0.60
elektron workflow        ~$0.50-0.80
```

### Tier 3 keywords (broader, more expensive)
```
audio converter mac      ~$1.50-3.00  (set lower bid, expect lower placement)
wav converter            ~$1.00-2.00
batch audio              ~$0.50-1.00
```

### Setup
1. App Store Connect → App Analytics → Apple Search Ads
2. Start with **Basic** mode (Apple optimizes automatically) for first 30 days
3. After data: switch to **Advanced** with custom bids on your highest-converting keywords
4. Use **negative keywords** to exclude irrelevant searches (e.g., "youtube to mp3")

### What to measure
- **Tap-Through Rate (TTR)** — should be >2% with good screenshots
- **Conversion Rate (CR)** — should be >30% for an installed app
- **Cost Per Acquisition (CPA)** — for a $0.99 app, keep under $0.50 to break even on revenue alone (LTV is what matters longer term)

---

## 5. In-App Events

Apple lets you promote events directly in App Store search (badge on your app card).

### Suggested event #1 — Major version release
**Title:** "Version 1.3 is here"
**Event period:** Day before to 7 days after release

### Suggested event #2 — App Store anniversary
**Title:** "1 year on the App Store!"
**Event period:** Around your launch anniversary

### Why this matters
Apps with active In-App Events show up in special browse sections and get a "Promoted" indicator in search.

---

## 6. App Icon Optimization

Your current icon (wave bars on black) is fine but could be optimized for thumbnail visibility.

**Issues to consider:**
- At small sizes (16x16, 32x32 in search results), the wave bars become hard to read
- The dark background blends with App Store dark mode
- No color variation — competing apps use brighter colors to stand out

**A/B test ideas (via Product Page Optimization):**
- Lighter background option (white or muted)
- Single bold wave instead of three (cleaner at small sizes)
- Mono "M" letter as primary element

Optional — keep current icon, just test as part of the A/B framework.

---

## 7. Reviews & Ratings Strategy

Reviews are the SINGLE biggest factor for App Store ranking.

### What we've done
- ✅ Added in-app review prompt (`ReviewPrompt.swift`) — fires after 3 successful conversions
- ✅ Responded to existing 2 reviews

### What you should do
- **Ship a new version** (v1.2.1 or v1.3.0) to deploy the review prompt
- **Email outreach** to anyone who's reached out about the app — gently ask for a review
- **Add a subtle "Enjoying the app? Rate us" link** in the app's About menu (not just rely on the system prompt)

### Target metrics
- **30+ reviews** before serious paid ad spending (more reviews = better ad efficiency)
- **4.5+ average** — respond to any 3-star reviews quickly and helpfully
- **At least 5 reviews per quarter** sustained

---

## 8. Mac App Store Algorithm Insights

Things Apple's ranking algorithm cares about (in rough order of importance):

1. **Number of installs in last 30 days** — velocity matters most
2. **Number of ratings (especially recent)** — review prompt is critical
3. **Star rating average** — 4.5+ is the threshold
4. **Title keyword match** — exact match in title is very heavy
5. **Subtitle keyword match** — second most heavy
6. **Keywords field match** — third
7. **Description keyword density** — minor weight (but still matters)
8. **Update cadence** — apps that ship updates rank higher
9. **Crash rate / app health** — bad apps get demoted
10. **Engagement** — sessions per user, retention

### What this means for you
- The review prompt is the #1 thing you can ship now to improve rankings
- Title/Subtitle changes will require app review and 1-2 weeks to see ranking effect
- Apple Search Ads also improves organic ranking (Apple rewards apps that pay)
- Shipping updates every 4-8 weeks is good for ranking signals

---

## 9. Recommended Action Order

**This week:**
1. Update keywords field to 100/100 chars (Issue #12) — 1 minute
2. Set up Custom Product Pages (3 of them) — 30 minutes
3. Set up Apple Search Ads Basic — 15 minutes
4. Update App Store description with new metadata from SEO_STRATEGY.md — 10 minutes

**This month:**
5. Take new screenshots for v1.2 (Issue #8) — 2-3 hours
6. Make App Preview Video (Issue #9) — 2-4 hours
7. Set up Product Page Optimization A/B test — 30 minutes after screenshots
8. Ship v1.3.0 with the in-app review prompt — release work

**This quarter:**
9. German localization (Issue #19)
10. Danish localization (Issue #20)
11. In-App Events for version releases
12. Apple Search Ads → Advanced mode with optimized bids

---

## 10. Tracking ASO Performance

Check weekly in App Store Connect → App Analytics:

- **Impressions** — how many people see your app
- **Product Page Views** — how many click through
- **Conversion Rate** (PPV → Install) — should be >30%
- **Search vs. Browse vs. Web Referrer** — where downloads come from
- **Average Position for top keywords** (in App Analytics → Search Term Insights)

Set monthly goals like:
- Month 1: 100 downloads
- Month 3: 300 downloads
- Month 6: 1,000 downloads

These are realistic for a $0.99 niche utility with proper ASO.
