# Xcode Cloud – hvor du finder det

Xcode Cloud ligger **ikke** under Product-menuen. Du finder det her:

## Hvor finder du Xcode Cloud?

1. Åbn **Report Navigator** i Xcode:
   - Klik på **Report Navigator-ikonet** i den venstre navigatorlinje (ikonet der ligner en taleboble / liste med checkmarks), **eller**
   - Brug **View → Navigators → Show Report Navigator** (kort: **⌘9**).

2. I Report Navigator:
   - Øverst kan du skifte mellem **All**, **Crashes**, **Integrations** osv.
   - Vælg **Integrations** (eller **Cloud** – navnet kan variere lidt med Xcode-version).
   - Her ser du eksisterende Xcode Cloud-workflows og builds.
   - For at **oprette dit første workflow**: Klik **"+"** eller **"Create Workflow"** / **"Get Started"** (teksten afhænger af Xcode). Hvis du ikke har tilknyttet appen til Xcode Cloud endnu, vises en guide til at tilknytte repo og oprette workflow.

**Kort:** **⌘9** → Report Navigator → **Integrations** / **Cloud** → opret workflow derfra.

---

## Krav for at Xcode Cloud vises og virker

### 1. Apple-konto og rolle

- Du skal være logget ind med en **Apple ID**, der har **Apple Developer Program** (betalt medlemskab).
- **Xcode → Settings (⌘,)** → **Accounts** → tjek at din Apple ID viser "Apple Developer Program" / "Developer".
- Rollen skal tillade at oprette apps i App Store Connect (Account Holder, Admin, App Manager, eller Developer/Marketing med rettighed til at oprette app records).

### 2. Git-remote

- Xcode Cloud bygger fra et **Git-repository med en remote** (fx GitHub).
- **Source Control navigator (⌘2)** → tjek at der er en **remote** (fx `origin` → `https://github.com/JarlLyng/It-s-mono-yo-.git`).
- Åbn gerne projektet ved at **klone** repo’et (File → Clone / `git clone`), så remote er sat fra start.

### 3. Scheme er delt

- **Product → Scheme → Manage Schemes** → "SampleDrumConverter" skal have **Shared** slået til (projektet har allerede scheme i `xcshareddata/xcschemes/`).

---

## Efter workflow er oprettet

- Vælg **GitHub** som kilde og godkend adgang.
- Vælg **branch** (fx `main`).
- Xcode Cloud kører herefter byg og (valgfrit) tests ved push/PR.

---

**Reference:** [Get started with Xcode Cloud](https://developer.apple.com/xcode-cloud/get-started/) (Apple). Xcode Cloud kræver Xcode 15.0 eller nyere.
