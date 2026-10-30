# App Store screenshots + App Preview capture

Status na 2026-10-29 (wieczór): **zrobione**. Screenshoty i App Preview dla obu urządzeń leżą w `StoreAssets/Output/`.
App Preview ma ok. 33 s, więc przekracza limit, ale użytkownik sam go przytnie. Wideo fixture trwa 37,93 s.
Poprawki po pierwszym przebiegu:
- `ScreenshotDemo.saveWalkthroughWish()` zapisuje życzenia Mii do Biblioteki, bo w prawdziwym flow robi to `VideoViewModel`.
- `capture.py` ustawia symulatorowi region `en_US`, żeby zegar pokazywał „9:41”, a nie „09:41”, i wyłącza symulator po
  każdym przebiegu.

## Cel (wymagania użytkownika)

- Tylko język **EN**.
- Zrzuty ekranu i App Preview (wideo) dla **iPhone'a** (apka jest iPhone-only, `TARGETED_DEVICE_FAMILY: 1`, więc
  iPad i Watch odpadają):
  - **6,9″**: iPhone 17 Pro Max, zrzuty 1320×2868 (ten rozmiar App Store wymaga)
  - **6,3″** („iPhone with Dynamic Island, medium display”): iPhone 17 Pro, zrzuty 1206×2622
  - App Preview dla obu: **886×1920**, 30 fps, **15–30 s**
- Wideo ma być naturalnym przejściem przez ekrany:
  1. Start (1–2 s)
  2. **Wybór okazji** (Birthday)
  3. Formularz: wpisywanie zaczyna się dopiero po animacji przejścia i wygląda na pisanie przez człowieka
  4. Ekran generowania i loader **pomijamy**
  5. Ekran wygenerowanych życzeń
  6. Ekran wyniku z wideo i audio: **wideo ma ruszyć**
- **Zrzut po każdym ekranie, zanim apka przejdzie dalej.** Całość nagrywamy (robię to sam przez `simctl`).
- Dodatkowe zrzuty: **Biblioteka** i ekran **przykładów** („Hear an example”). Robione po nagraniu, poza App Preview.
- Życzenia średniej długości, z kilkoma faktami o solenizantce.

## Co jest zrobione

### Tryb demo w apce (tylko DEBUG)

- `Packages/CorePackage/Sources/Domain/ScreenshotDemo/ScreenshotDemo.swift`
  - Włącza go flaga `-ScreenshotDemo`, a `-ScreenshotDemoPrepare` służy do renderu wideo fixture.
  - `configureLaunch()` wywołuje się z `WishSpeakerApp.init`. W trybie demo podmienia `wishGenerationService`
    przez `prepareDependencies` na `ScreenshotDemoWishGenerationService`, więc nie ma loadera.
    W trybie prepare uruchamia `prepareFixtures()`.
  - `run(step) { … }` uruchamia każdy krok raz, w kolejności `Step.allCases`. Używa niestrukturalnego `Task`, bo
    `.task` zostałby anulowany po pushu następnego ekranu.
  - `capture(name)` zapisuje `Documents/ScreenshotDemo/<name>.ready` i czeka na `<name>.done` od skryptu
    (timeout 15 s).
  - `mark(name)` zapisuje `<name>.mark`, czyli sam znacznik czasu: `preview-start`, `video-start`, `preview-end`,
    `finished`, `prepared`, `prepare-failed`.
  - `type(text)` wpisuje tekst znak po znaku z losowym opóźnieniem 0,04–0,09 s, dłuższym po spacji i interpunkcji.
- `.../Domain/ScreenshotDemo/ScreenshotDemo+Fixtures.swift`
  - Odbiorca: „Mia, my best friend”. Szczegóły: „Turning 30! Ran her first marathon this year, moved to Lisbon and
    adopted a rescue dog called Pickle.”
  - Trzy warianty: warm (ok. 95 słów, to on trafia do wideo), natural, light.
  - `attachVideo()` ustawia `creationManager.generatedVideoAsset` na `screenshot_demo.mp4`.
  - `seedLibrary()` dodaje wpis Sarah (Thank You, voice, `screenshot_demo_voice.mp3`) sprzed 3 dni i Mom & Dad
    (Anniversary, sam tekst) sprzed 9 dni.
  - `prepareFixtures()` renderuje prawdziwe wideo przez `videoGenerationService`: backend i ElevenLabs, głos
    `VoiceCatalog.femaleVoiceIDs[0]`, ffmpeg na urządzeniu. Potem zmienia nazwy na `screenshot_demo.mp4` i
    `screenshot_demo_thumbnail.jpg`, a długość zapisuje w `prepared.mark`.
  - ⚠️ `Fixture.videoDuration = 0.0`: **placeholder**. Po `--prepare` trzeba wpisać prawdziwą długość.
- Hooki na ekranach, każdy owinięty w `#if DEBUG`:
  - `StartFeature/StartView.swift`, krok `.start`: znacznik `preview-start`, potem zrzut `01-start` i tap
    „Create wish”.
  - `StartFeature/StartView.swift`, krok `.libraryAndExamples` (po powrocie z flow): dodaje wpisy do biblioteki,
    otwiera Bibliotekę i robi `06-library`, wraca, otwiera Examples i robi `07-examples`, na koniec `finished`.
  - `OccasionSelectionFeature/OccasionSelectionView.swift`: zrzut `02-occasion`, potem wybór Birthday.
  - `FormFeature/FormView.swift`: fokus, wpisanie obu pól, schowanie klawiatury, zrzut `03-form`, Generate.
  - `WishesFeature/WishesView.swift`: zrzut `04-wishes`, `attachVideo()`, potem „Use this wish” (warm).
  - `LibraryFeature/WishResultView.swift` (prywatne rozszerzenie na końcu pliku, żeby zmieścić się w
    `type_body_length`): `play()` i znacznik `video-start`, po 3,5 s zrzut `05-result`, po 3,5 s znacznik
    `preview-end`, na koniec Home.
- `Targets/MobileApp/Sources/WishSpeakerApp.swift`: `#if DEBUG ScreenshotDemo.configureLaunch() #endif`.

### Skrypt `StoreAssets/capture.py` (stdlib Python, `python3`)

- `python3 StoreAssets/capture.py --prepare` jednorazowo renderuje wideo do `StoreAssets/Fixtures/` i wypisuje
  jego długość.
- `python3 StoreAssets/capture.py [--skip-build] [--devices "iPhone 17 Pro Max" "iPhone 17 Pro"]`:
  - Build: `xcodegen` i `xcodebuild` (Debug, `generic/platform=iOS Simulator`, **`ARCHS=arm64`**, bo
    FFmpegKit ma wycinek symulatora tylko pod arm64). DerivedData trafia do `build/StoreAssets`.
  - Używa **wyłącznie własnych symulatorów `StoreAssets <model>`** i sam je tworzy na najnowszym runtime iOS.
    Nigdy nie dotyka symulatorów użytkownika.
  - Czysty pasek statusu (9:41, Wi-Fi, 100%), reinstalacja apki, skopiowanie fixture do `Documents`:
    `screenshot_demo.mp4`, `screenshot_demo_thumbnail.jpg` i `thankyou_demo.mp3` jako
    `screenshot_demo_voice.mp3`.
  - `simctl io recordVideo`, launch z `-ScreenshotDemo -AppleLanguages (en) -AppleLocale en_US`, obsługa
    handshake `.ready` → screenshot → `.done`.
  - ffmpeg: przycięcie od `preview-start` do `preview-end`, skalowanie do 886×1920 z przycięciem, 30 fps, H.264
    10M. Audio to narracja z `screenshot_demo.mp4` przesunięta o `video-start`, a wcześniej cisza (AAC 256k,
    48 kHz, stereo).
  - Wynik: `StoreAssets/Output/<model>/01-start.png … 07-examples.png`, `raw_recording.mp4`, `app_preview.mp4`.
- `.gitignore`: dodane `/build/` i `StoreAssets/Output/`.

## Blokada (powód przerwy)

- `simctl boot` każdego nowego symulatora (iOS 26.3 i 27.2) kończył się błędem
  `launchd failed to respond … Failed to start launchd_sim: could not bind to session`, także poza sandboxem.
  Inne polecenia `simctl` wisiały.
- Symulator użytkownika **iPhone 17 (6CA4E4D0-DFB3-477A-8477-A83435773006)** z apką `Stage_Biedronka` mógł dostać
  override paska statusu, bo polecenie zawisło. Gdyby zegar pokazywał 9:41:
  `xcrun simctl status_bar 6CA4E4D0-DFB3-477A-8477-A83435773006 clear`
- Sprzątnięte: zabite zawieszone procesy z tej sesji i usunięte dwa symulatory, które ta sesja utworzyła.
- Rozwiązanie: restart CoreSimulatora (`xcrun simctl shutdown all; killall -9 com.apple.CoreSimulator.CoreSimulatorService`)
  albo restart lub aktualizacja systemu, co użytkownik właśnie robi.

## Pozostałe kroki

1. [x] Po restarcie sprawdzić, czy symulator się bootuje.
2. [x] `python3 StoreAssets/capture.py --prepare --devices "iPhone 17 Pro Max"`: render wideo przez backend
   (jedno wywołanie ElevenLabs). Backend: `https://santa-voice-backend.onrender.com`, może potrzebować chwili na
   rozgrzanie.
3. [x] Wpisać długość z wyjścia skryptu do `Fixture.videoDuration` w `ScreenshotDemo+Fixtures.swift`.
4. [x] `python3 StoreAssets/capture.py` dla obu urządzeń.
5. [x] Zweryfikować wynik: obejrzeć PNG-i i klatki z `app_preview.mp4` (`ffmpeg -ss … -frames:v 1`).
   - Czy przy wpisywaniu widać klawiaturę ekranową (symulator headless powinien ją pokazywać)?
   - Czy na życzeniach nie mignął loader?
   - Czy wideo na ekranie wyniku gra (`05-result`) i czy nie zasłaniają go kontrolki AVPlayer?
   - Czy audio jest zsynchronizowane z ruszeniem wideo?
   - Czy długość mieści się w 15–30 s? Jeśli nie, dostroić pauzy w hookach.
   - Czy rozdzielczości PNG to 1320×2868 i 1206×2622?
   - Czy Biblioteka ma 3 wpisy, a Examples wygląda dobrze?
6. [ ] Ewentualnie: iPhone Duo. Jest zakładka w App Store Connect, ale wymagania nieznane, więc najpierw zapytać
   użytkownika.
7. [ ] Pokazać użytkownikowi wyniki. **Nie robić `git add` ani commitów**, użytkownik robi to sam.

## Decyzje

- Tryb demo jest w kodzie apki (DEBUG), a nie w XCUITest. Daje pełną kontrolę nad tempem pisania, nie wymaga
  targetu UI testów i nie pokazuje UI test runnera.
- Wideo fixture to prawdziwy render dla wymyślonych życzeń, a nie `birthday_demo.mp4` (Emma). Dzięki temu napisy
  w wideo zgadzają się z tekstem na ekranie.
- Biblioteka i Examples są poza App Preview, żeby zmieścić się w 30 s.
- Odpowiedzi do użytkownika piszemy po polsku.
