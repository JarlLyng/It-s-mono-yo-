# App Review: It's mono, yo!

## Findings
- Medium: `customStatusMessage` bliver aldrig nulstillet, så den overskriver altid de dynamiske statusbeskeder (fx konverteringsstatus). Det gør statuslinjen permanent "stuck" efter første custom message. `SampleDrumConverter/ContentView.swift:235`, `SampleDrumConverter/ContentView.swift:505`. Anbefaling: nulstil `customStatusMessage` ved state-skift (fx når konvertering starter/slutter) eller drop den som override.
- Low: Status-teksten refererer til en "Add WAV Files"-knap, som ikke findes i UI’et. `SampleDrumConverter/ContentView.swift:245`. Anbefaling: opdater teksten til den faktiske handling (fx "Select WAV Files" eller "Click to select WAV files").
- Low: `isProcessing` bliver aldrig sat, så statuslinjen viser ikke "Converting..." under faktisk konvertering og kan vise misvisende tekst. `SampleDrumConverter/ContentView.swift:224`, `SampleDrumConverter/ContentView.swift:239`. Anbefaling: sæt `isProcessing` når konvertering starter/stopper, eller fjern logikken helt.
- Low: Der oprettes security-scoped bookmark-data med kommentar om "persistent access", men data gemmes aldrig, så adgangen kan ikke overleve en app-genstart. `SampleDrumConverter/ContentView.swift:875`, `SampleDrumConverter/ContentView.swift:904`. Anbefaling: gem bookmark-data (fx i UserDefaults/Keychain) eller fjern "persistent"-delen og kommentaren.
- Low: `testFileSizeValidation` allokerer en 101MB `Data` i hukommelsen, hvilket kan gøre tests tunge i CI. `SampleDrumConverterTests/AudioConversionTests.swift:62`. Anbefaling: lav en sparse fil via `FileHandle`/`truncate` i stedet for at allokere hele filen i RAM.

## Open Questions / Assumptions
- Skal security-scoped adgang være vedvarende på tværs af app-genstarter, eller er det kun relevant for den aktuelle session?

## Testing Gaps
- `testStereoToMonoConversion` bliver altid skippet, fordi `test_stereo.wav` ikke findes i repoet. `SampleDrumConverterTests/AudioConversionTests.swift:10`.
- `testErrorStates` er reelt tom og validerer ikke UI-fejlflowet. `SampleDrumConverterUITests/SampleDrumConverterUITests.swift:63`.
- Ingen tests dækker drag-and-drop med sandboxede security-scoped URL’er.
