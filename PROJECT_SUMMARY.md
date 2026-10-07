# WishSpeaker — podsumowanie projektu

Ten plik to kontekst dla przyszłych sesji z tym projektem **oraz** materiał startowy
dla kolejnej aplikacji o podobnym charakterze (SwiftUI + swift-dependencies + FastAPI
backend-proxy do zewnętrznych AI API). Pisany pod koniec pierwszej fazy budowy —
core flow (tekst → głos → wideo) działa end-to-end, paywall i polish wciąż przed nami.

## Co to za produkt

Aplikacja do generowania spersonalizowanych życzeń (urodziny, rocznice, święta itd.):
użytkownik wpisuje dla kogo i w jakiej okazji → AI generuje 3 warianty tekstu
(warm/natural/light) → użytkownik może dogenerować głos (TTS) → opcjonalnie wideo-kartkę
z karaoke-napisami. Każdy krok jest opcjonalny i zapisywalny osobno — to świadoma decyzja
produktowa, nie uproszczenie (patrz sekcja "Wzorce produktowe" niżej).

## Architektura — dwa repozytoria

1. **`WishSpeaker`** (ten) — iOS, SwiftUI, Swift 6 strict concurrency
2. **`WishSpeaker-Backend`** — FastAPI, Python 3.9, proxy do OpenAI + ElevenLabs
3. **`WishSpeaker-Backend-Playground`** — sandbox do eksperymentów (ffmpeg, moviepy),
   nieprzeznaczony do deploya, patrz sekcja "Playground" niżej

Zasada nadrzędna: **zero kluczy API po stronie klienta**. Wszystko — OpenAI, ElevenLabs —
idzie przez backend-proxy. iOS nie zna żadnego sekretu, tylko `baseURL` backendu.

---

## iOS — struktura modułów

`CorePackage` (SPM), Swift 6.0, iOS 17+, podzielony per-feature, mirror Pepco's
`{X}Domain`/`{X}Feature`:

- **DesignSystem** — komponenty wizualne bez wiedzy o modelu domenowym (AudioPlayerView,
  PrimaryButton, SecondaryButton, WSBackButton)
- **Domain** — modele + Managery stanowe (`WishCreationManager`, `WishLibraryManager`),
  `Networking/` (APIClient, DTOs), `Occasion/`, `Persistence/`, `Wish/` (serwisy generacji)
- **Localizations** — `L10n` generowany przez SwiftGen z `.strings`
- **Resources** — obrazy/fonty generowane przez SwiftGen (`Resource`, `FontFamily`)
- **SharedFeatureComponents** — UI reużywane między Features, wymagające modeli Domain
  (WishCard, WishLibraryCard, PlaybackState, VoicePlaybackCoordinator, VoicePreviewPlayer)
- **9 `{X}Feature` targetów**, każdy jako jeden ekran/flow: StartFeature,
  OccasionSelectionFeature, FormFeature, WishesFeature, CreateFeature,
  PackageSelectionFeature, FinalWishFeature, LibraryFeature, ExampleWishesFeature

Zależności idą zgodnie z grafem nawigacji (Feature importuje następny ekran, do którego
może nawigować), nigdy odwrotnie. Wszystko → Domain + DesignSystem + Localizations.

### Kluczowe wzorce techniczne (przenieś 1:1 do nowej appki)

**DI — swift-dependencies, prawdziwy pakiet Point-Free, nie custom reimplementacja.**
Wzorzec: `protocol XService` + `MockXService`/`LiveXService` + `struct XServiceKey:
DependencyKey` + `extension DependencyValues`. W tym projekcie zarejestrowano 6 kluczy —
`APIEnvironmentKey`, `WishGenerationServiceKey`, `VoiceGenerationServiceKey`,
`VoiceMetadataServiceKey`, `WishCreationManagerKey`, `WishLibraryManagerKey`.

Dla **stanowego** `@MainActor` Managera (musi przetrwać między ekranami, inaczej niż
typowy bezstanowy client z biblioteki): osobny `struct XKey: DependencyKey` (NIE
`extension Manager: DependencyKey` bezpośrednio na klasie `@MainActor` — to nie
kompiluje się w Swift 6: "conformance crosses into main actor-isolated code"), z
`static var liveValue: Manager { @MainActor get { Manager() } }`. Biblioteka cache'uje
`liveValue` po pierwszym dostępie, więc computed property wciąż daje singleton.

**Nawigacja — system `NavigationStack`/`NavigationPath`, zero custom Router.**
Pepco's `@Routable`/`@Presentable` Router świadomie NIE został przeniesiony — zakłada
w pełni custom nav bar (ukrywa systemowy), a ta appka chce systemowego zachowania
(collapsing header, Liquid Glass, system back button). Jeden współdzielony
`NavigationPath` trzymany w `@State` na poziomie `App`, wstrzykiwany przez custom
`EnvironmentKey` (`\.createFlowPath: Binding<NavigationPath>`) do wszystkich ekranów
flow, routing przez jeden `enum CreateFlowRoute: Hashable, Sendable` i jedno
`navigationDestination(for:)` w korzeniu. Pułapka: `EnvironmentKey.defaultValue` dla
`Binding<NavigationPath>` MUSI być `static var` (computed), nie `static let` — inaczej
błąd "not concurrency-safe because non-Sendable type may have shared mutable state",
który kaskadowo psuje type inference w dziesiątkach niepowiązanych plików.

**ViewModel/View/Preview — zawsze 3 osobne pliki**, nigdy współdzielone. Ekran bez
stanu wartego ViewModela (np. ExampleWishesFeature) może pominąć plik ViewModela —
nie twórz pustego dla samej konsekwencji. VM action handlery nazwane `did{Something}`,
`internal` (bez modyfikatora) dla testowalności. Views bindują się do VM properties
przez `$viewModel.xyz` — brak `fileprivate` jako granicy dostępu (to był wzorzec
z czasów współdzielonego pliku, teraz nieaktualny).

**Managery vs ViewModel**: Manager (`WishCreationManager`) NIE jest `@Observable`
(żeby uniknąć workaroundu z unsafe singletonem). Konsekwencja: ViewModel wyświetlający
pole Managera musi skopiować je do własnego `@Observable` property w `didAppear()` —
czytanie `viewModel.creationManager.x` bezpośrednio w `body` nie odpali re-render.

**Zasoby (obrazy/fonty) — zawsze przez SwiftGen, nigdy `Bundle.main`/`Image(_:bundle:)`.**
Kod wewnątrz pakietu SPM odwołujący się do `.main` działa przypadkiem w buildzie na
urządzeniu, ale cicho nie znajduje zasobu w Xcode Previews (inny kontekst bundle'a).
`Resource.xyz.swiftUIImage` i `FontFamily.Name.weight.swiftUIFont(size:)` działają
w obu kontekstach. Wygenerowane `FontConvertible`/`ImageAsset` wymagają ręcznego
`extension X: @unchecked Sendable {}` (jedna z nielicznych legalnych lokalizacji tego
workaroundu w kodzie — bo to generowany, niemutowalny typ, nie ręczny obejście izolacji).

**App Icon zostaje w `MobileApp` target** (bo `ASSETCATALOG_COMPILER_APPICON_NAME`
wymaga go w głównym bundle), wszystko inne UI-facing (obrazy, fonty) w `Resources` SPM.

**xcodegen gotcha**: nie ma top-level `resources:` na targecie — silnie ignorowane
bez błędu. Zasoby muszą być pod `sources:` z `buildPhase: resources`, a folder
`.xcassets` wskazany bez `type:` override (xcodegen wywnioskuje
`folder.assetcatalog` z rozszerzenia — wymagane żeby `actool` je skompilował;
wymuszenie `type: folder` kopiuje je surowo i asset catalog cicho nie działa).

### Stan testów — **brak w ogóle**

CLAUDE.md deklaruje że każdy Feature/Domain target powinien mieć odpowiadający test
target, ale w praktyce **0 plików testowych w całym repo**. To świadomy dług tej fazy
(szybkość iteracji nad UX ponad coverage), nie przeoczenie — ale do adresowania przed
jakimkolwiek realnym wydaniem, zwłaszcza logika Managerów (`WishCreationManager`
state transitions) i serwisów sieciowych.

### README.md jest nieaktualny względem CLAUDE.md i faktycznego kodu

README opisuje `@Routable`/`@Presentable` Router i `PreviewProvider` — CLAUDE.md
(i faktyczny kod) jawnie to odrzuca na rzecz systemowej nawigacji i `#Preview`. Do
poprawienia przy najbliższej okazji, żeby nie mylić kogoś, kto czyta tylko README.

---

## Backend — struktura i wzorce

Płaski FastAPI, Python 3.9 (**ważne ograniczenie**: `Optional[X]`, nie `X | None` —
składnia `|` dla typów nie działa w 3.9).

```
app.py                  — wszystkie endpointy, CORS allow-all, UTF8JSONResponse
models.py               — Pydantic models (request/response)
services/
  openai_service.py     — generowanie tekstu (gpt-5-mini)
  elevenlabs_service.py — TTS + alignment→word timestamps
  voices.py             — mapowanie język/płeć → voice_id, curated voices allowlist
  video_service.py       — render wideo (ffmpeg: ASS karaoke + loop + outro + xfade)
  prompts/{lang}.py      — jeden plik per język (pl/en/de/fr/it/es), per-language prompt
assets/video/            — tlo.mp4, outro.mp4 (statyczne assety renderu)
render.yaml              — Render.com deploy config
```

### Endpointy

- `POST /api/generateWishes` — 3 warianty tekstu (warm/natural/light)
- `POST /api/regenerateWish` — regeneracja jednego wariantu, unika powtórzenia
- `POST /api/generateAudio` — TTS, zwraca surowe MP3 bytes (StreamingResponse)
- `POST /api/generateVideoAudio` — TTS z timestampami (JSON: audio_base64 + word_timestamps)
- `POST /api/generateVideo` — pełny render wideo (TTS+timestamps→ffmpeg→MP4 bytes)
- `GET /api/voices/{voice_id}` — proxy metadanych głosu ElevenLabs, **odrzuca** każde
  `voice_id` spoza allowlisty — appka nigdy nie może przeglądać pełnego katalogu
  ElevenLabs przez ten proxy

### Wzorzec promptów AI — osobny plik per język, nie jeden uniwersalny z flagą

`services/prompts/{pl,en,de,fr,it,es}.py`, każdy z `build_instruction(req) -> str`.
Decyzja świadoma: prompt pisany natywnie w danym języku (nie angielski prompt z
instrukcją "respond in X") daje zauważalnie lepszą gramatykę i naturalność dla modeli
takich jak gpt-5-mini. Koszt: zmiana promptu trzeba powielić w 6 plikach ręcznie.

**Lekcja z tej sesji (do zapamiętania dla nowej appki)**: nie wstrzykuj danych
personalizujących (imię, relacja) jako sztywnej frazy na początku każdej wygenerowanej
wariacji — model będzie to traktował jako szablon do kopiowania, co daje identyczne,
sztampowe otwarcia we wszystkich wariantach ("Imię, moja żono" w kółko). Zamiast tego
opisz te dane jako **informację kontekstową dla modelu, nie frazę do wklejenia**,
i explicite poproś o zróżnicowanie sposobu wplecenia (albo pominięcia) imienia/relacji
między wariantami.

**Model**: `gpt-5-mini` (nie `gpt-4o-mini` — wyraźnie lepsza gramatyka PL), z
`reasoning_effort="low"` zamiast `temperature` (gpt-5-mini nie wspiera custom
temperature), `response_format={"type": "json_object"}`.

### ElevenLabs — curated voices jako osobna, mniejsza allowlist

`VOICE_IDS` (pełna macierz język×płeć, 12 kombinacji) służy do TTS ogólnego i
**obecnie wszystkie wskazują na jeden `DEFAULT_VOICE_ID`** — świadomie tymczasowe,
komentarz w kodzie to flaguje. `CURATED_VOICE_IDS` to osobna, mniejsza lista (dokładnie
2 głosy) używana wyłącznie przez Voice Selection UI — rozdzielenie "co appka faktycznie
oferuje do wyboru" od "co technicznie jest dostępne do TTS" jest świadome i warto je
powielić (łatwo rozszerzyć ofertę głosów bez zmiany logiki TTS, i odwrotnie).

Wymaga uprawnienia `voices_read` na kluczu API ElevenLabs (osobne od uprawnienia do
samego generowania audio) — łatwe do przeoczenia przy pierwszym seedowaniu klucza.

### Deploy — Render.com, free tier

`render.yaml`: `env: python`, `startCommand: uvicorn app:app --host 0.0.0.0 --port 10000`.
4 sekrety (`OPENAI_API_KEY`, `ELEVENLABS_API_KEY`, `ELEVENLABS_VOICE_ID`,
`ELEVENLABS_MODEL_ID`) jako `sync: false` — wpisywane ręcznie w dashboardzie, nie
trzymane w repo nawet jako placeholder.

### Stan testów — brak, jak w iOS

Backend też nie ma testów. Do adresowania razem z iOS przed realnym wydaniem.

---

## Moduł wideo (najświeższa praca, warta osobnego opisu)

`services/video_service.py` przenosi logikę ffmpeg z playgroundu do backendu i
rozszerza ją. Pipeline:

1. ElevenLabs `/with-timestamps` → flat lista `word_timestamps` (text/start_ms/end_ms)
2. `_group_words_into_pages()` — grupowanie słów we "strony" napisów po limicie znaków
   (różni się od oryginalnego playground skryptu, który czytał gotowe `pages` z JSON —
   tu trzeba było ten krok dopisać samemu, bo backend ma tylko flat listę słów)
3. `_generate_karaoke_ass()` — generuje plik `.ass` z karaoke timing (`\K` tagi per
   słowo), font Baskerville, wyśrodkowany tekst, fade in/out na każdej stronie
4. ffmpeg render: tło w nieskończonej pętli (`loop=loop=-1`) + napisy wypalone przez
   filtr `subtitles=` + audio życzeń, `-shortest` żeby nie przeciągać tła dłużej niż audio
5. **Outro doklejany na końcu** — osobny krótki klip z własnym audio (branding)
6. Przejście main→outro przez `xfade`/`acrossfade` (crossfade 0.6s), nie twardy cut

### Pułapka, która kosztowała najwięcej czasu w tej sesji

ffmpeg `concat` demuxer (`-f concat -c copy`) **cicho gubi drugi segment** gdy pliki
mają różny framerate/sample-rate (tu: main 30fps/44.1kHz vs outro źródłowo 24fps/32kHz)
— **bez błędu**, czas trwania wynikowego pliku wygląda tylko odrobinę za krótki, więc
łatwo przeoczyć że coś w ogóle nie zadziałało. Diagnoza wymagała porównania
`ffprobe -show_entries stream=r_frame_rate,time_base` między plikami. Fix: wymusić
identyczny `fps=`/`-ar` na etapie normalizacji drugiego klipu PRZED jakąkolwiek próbą
`-c copy` konkatenacji. Ostatecznie i tak zastąpiony przez `xfade`/`acrossfade` (wymaga
re-encode, ale daje płynne przejście zamiast twardego cięcia) — **ta ogólna lekcja
("concat demuxer + stream copy wymaga identycznych parametrów kodeka, inaczej cicho
się psuje") przenosi się 1:1 na każdy przyszły projekt łączący niezależnie wyrenderowane
klipy wideo.**

### Gdzie szukać teł/assetów wideo (research z tej sesji)

Animowane pętle "ambient background" (bokeh, cząsteczki, gradient) — najlepszy
stosunek jakość/koszt: **Envato Elements** (abonament, tysiące gotowych seamless
loopów 4K). **Pexels/Pixabay** jako darmowy punkt startowy do testów (źródło
obecnego `tlo.mp4`). Do w pełni custom stylu: **Runway/Kling AI** (text-to-video,
prompt typu "soft golden bokeh particles, seamless loop, warm tone") — tańsze niż
zamawianie u grafika, dobre gdy styl wizualny marki nie jest jeszcze ustalony.

Rekomendacja produktowa: animowane tła przypisane do **kategorii tonu wariantu**
(warm/natural/light) lub kategorii okazji, NIE do każdej pojedynczej okazji osobno —
inaczej macierz assetów rośnie bez końca.

---

## Playground — trzy porzucone/eksperymentalne podejścia

`WishSpeaker-Backend-Playground` ma trzy niezależne eksperymenty renderu wideo, nie
jeden:

- **`test-ffmpeg/`** — finalne podejście, przeniesione do backendu: ffmpeg + plik
  `.ass` z karaoke timing, osobne `tlo.mp4`/`outro.mp4`
- **`test-ffmpeg-working-simple/`** — wcześniejszy, uproszczony prototyp (bez outro,
  inny zestaw plików testowych) — najwyraźniej pierwszy "działający" krok przed
  dodaniem outro i dopracowaniem
- **`test-srt-moviepy/`** — zupełnie inne podejście: biblioteka `moviepy` zamiast
  gołego ffmpeg, napisy w formacie `.srt` zamiast `.ass`/karaoke, trzy iteracje skryptu
  (`render.py`/`render_v1.py`/`render_v2.py`) — porzucone na rzecz ffmpeg+ASS,
  prawdopodobnie bo moviepy jest wolniejszy i mniej elastyczny dla efektu karaoke

**Wniosek do zapamiętania**: dla efektu "słowo podświetla się w rytm mówienia"
(karaoke captions), ffmpeg + ASS subtitle format z tagami `\K` bije moviepy pod
względem kontroli i wydajności. Warto od razu iść tą drogą w nowym projekcie zamiast
przechodzić przez tę samą eksplorację.

---

## Wzorce produktowe (nie tylko techniczne)

- **Każdy krok flow jest opcjonalny i osobno zapisywalny**: sam tekst → biblioteka;
  tekst+głos → biblioteka; tekst+głos+wideo → biblioteka. Użytkownik nie jest zmuszany
  do przejścia całej ścieżki żeby cokolwiek zachować. To wymaga ostrożnej synchronizacji
  stanu między `WishCreationManager` (draft w budowie) a `WishLibraryManager`
  (zapisane wpisy) — klasa błędów która się tu pojawiła: zapisanie głosu nie
  aktualizowało wcześniej zapisanego wpisu tekstowego, bo warunek zapisu sprawdzał
  tylko "czy już zapisane", nie "czy zapisana wersja ma aktualną zawartość".
- **Automatyczny zapis + disclaimer zamiast przycisku "Zapisz"** w momencie gdy
  powstaje kosztowny content (audio/wideo) — unika utraty wygenerowanego (i
  kosztującego) assetu przez zapomnienie o zapisaniu.
- **Dwie równoległe ścieżki ożywienia życzeń (Głos / Kartka wideo) na tym samym
  ekranie, nie zagnieżdżone jedna w drugiej** — bo wideo i tak zawiera audio jako
  swój wewnętrzny krok; dodawanie "stwórz samo audio" wewnątrz flow wideo byłoby
  duplikatem funkcji już dostępnej jako osobna, równorzędna opcja.
- **Back button z custom logiką po wygenerowaniu contentu**: po dotarciu do ekranu
  z finalnym audio/wideo, systemowy "cofnij o jeden ekran" jest złym UX (cofnąłby
  przez cały stos kreacji) — zamiast tego pop-to-root do Start. Zaimplementowane
  przez wariant `wsBackButton(customAction:)`, który **podmienia** całe zachowanie
  (if/else), nie dokleja się do domyślnego `dismiss()`.

---

## Co zostało świadomie odłożone (nie brakujące, tylko zaplanowane na później)

- Paywall / StoreKit — explicite poza zakresem obecnej fazy
- Testy jednostkowe — zero w obu repo, do zaadresowania przed realnym wydaniem
- Dźwięk "ding" w outro wideo — zaplanowany, nie zrobiony
- Produkcyjne animowane tła (patrz sekcja wyżej) — obecnie jeden placeholder `tlo.mp4`
- Font Baskerville w renderze wideo polega na systemowych fontach macOS (działa
  lokalnie przez fontconfig/libass) — **ryzyko**: produkcyjny deploy na Render.com
  (Linux) może nie mieć tego fontu zainstalowanego; nie zweryfikowane w tej sesji

## Dla nowej aplikacji — co przenieść bez zmian

1. Cały wzorzec DI (swift-dependencies + osobny `Key` struct dla stanowych Managerów)
2. NavigationPath + custom EnvironmentKey zamiast customowego Routera
3. SwiftGen dla L10n i Resources (nigdy `Bundle.main` w kodzie SPM)
4. Backend-proxy wzorzec: zero sekretów w kliencie, FastAPI jako jedyny posiadacz kluczy
5. Prompty AI: osobny plik per język, dane personalizujące jako kontekst nie szablon
6. ffmpeg + ASS (nie moviepy) jeśli potrzebne będą karaoke-style napisy w wideo
7. Rozdzielenie "pełna macierz technicznych opcji" od "curated lista do UI" (jak
   `VOICE_IDS` vs `CURATED_VOICE_IDS`) wszędzie tam, gdzie produkt oferuje węższy
   wybór niż to, co technicznie obsługuje backend
