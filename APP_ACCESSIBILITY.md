# App Accessibility – App Store Connect (macOS)

Brug denne liste, når du udfylder **App Accessibility** / **Accessibility Nutrition Labels** for **It's mono, yo!** i App Store Connect (under **App Information** → **Accessibility**).

---

## Anbefaling: Hvad du kan angive support for (Mac)

| Feature | Angiv support? | Note |
|--------|----------------|------|
| **VoiceOver** | Ja | SwiftUI-knap, Label, Text og menu har fornuftige standardlabels. Toolbar-menu har fået `.accessibilityLabel("More options")`. Test med VoiceOver (System Settings → Accessibility → VoiceOver) at alle trin (vælg filer, vælg mappe, konverter, færdig) kan gennemføres. |
| **Voice Control** | Ja | Standard SwiftUI-kontroller understøttes typisk. Test med Voice Control slået til. |
| **Larger Text** | — | **Ikke tilgængelig på Mac** ifølge Apple (kun iOS/iPadOS). Vises ikke som valg for macOS. |
| **Dark Interface** | Ja | Appen følger systemets lys/mørk-tilstand. |
| **Differentiate Without Color Alone** | Ja | Status vises med ikoner (fx checkmark, exclamationmark.triangle) samt farve. |
| **Sufficient Contrast** | Ja | IAMJARL design tokens med tydelig kontrast mellem tekst og baggrund. |
| **Reduced Motion** | Nej (med mindre du tester det) | Appen bruger animationer (.animation). Der er ikke implementeret respekt for "Reduce motion". Angiv **Nej** med mindre du tilføjer det og tester. |
| **Captions** | Lad stå uangivet / Nej | Ingen video i appen. Ikke relevant. |
| **Audio Descriptions** | Lad stå uangivet / Nej | Ingen video. Ikke relevant. |

---

## Valgfri: Accessibility URL

Du kan angive en **Accessibility URL** (fx din support-/marketing-side eller en dedikeret tilgængelighedsside), hvor brugerne kan læse mere om appens tilgængelighed. Fx:

- `https://itsmonoyo.iamjarl.com`  
eller  
- `https://github.com/JarlLyng/It-s-mono-yo-#readme`  

---

## Kort test før du angiver

1. **VoiceOver:** Slå VoiceOver til, kør gennem: åbn filer → vælg mappe → start konvertering → se færdig-skærm. Tjek at knapper og status er forståelige.
2. **Dark Interface:** Skift system til mørk tilstand og tjek at UI er læsbart.
3. **Differentiate Without Color Alone:** Tjek at du kan skelne "Pending / Converting / Completed / Failed" ud fra ikoner og tekst, ikke kun farve.

Når det er ok, kan du med god samvittighed angive **VoiceOver**, **Voice Control**, **Dark Interface**, **Differentiate Without Color Alone** og **Sufficient Contrast** som understøttet for Mac i App Store Connect.
