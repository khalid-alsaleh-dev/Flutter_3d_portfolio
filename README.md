# Flutter 3dPortfolio App 👏👍🔥

This project designed using figma and built using flutter.


## Demo URL
soon will be hosted 

  


## 💻 Requirements 

- Any Operating System (MacOS, Linux, Windows)
- Any IDE with Flutter SDK installed (Android Studio, VSCode etc)
- A little knowledge of Dart and Flutter

## Download The Project,Install Dependencies && Run The Project 
- Run the next command to Clone the repo to your machine `https://github.com/khalid-alsaleh-dev/Flutter_3d_portfolio`
- Run the next commands to install the required dependencies
  1. `cd <../path/to/Flutter_3d_portfolio>`
  2. `flutter pub get`
- Run the next command to run the project on the web `flutter run -d chrome`
- Build for hosting: `flutter build web --release --wasm` (output in `build/web`).
  Deploy the entire `build/web` directory, including its `assets` directory;
  deploying only `web/index.html` causes the `model_viewer_plus` JavaScript
  file to return 404 on GitHub Pages.
  - `--wasm` roughly doubles frame rate and halves memory in browsers with WasmGC (Chrome, Edge, Firefox, Safari 18.2+); other browsers automatically get the JavaScript build from the same output.
  - Serve with `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` so rendering runs on its own thread. `web/_headers` sets them on Netlify and Cloudflare Pages; on Firebase Hosting add them under `hosting.headers` in `firebase.json`.

## ⚔️ What's in v2
- Flutter 3.47 / Dart 3, Flame 1.38, flutter_animate 4.5, model_viewer_plus 1.10
- A hand-rolled 3D renderer (`lib/three_d/`): procedural katana, shuriken and kunai drawn with `Canvas.drawVertices`, no WebGL setup needed
- Scroll-driven scene (`lib/effects/blade_background.dart`): the hero katana slashes across the screen, then parks and spins as you scroll; shurikens spin faster the faster you scroll
- A pinned, scroll-scrubbed ninja duel (`lib/effects/ninja_duel.dart`) that plays backwards when you scroll up
- Sword-cut section headings, 3D tilt cards, a blade cursor trail with click sparks
- The projects dojo game, rebuilt to scale to any screen width: keyboard controls, or click a plate to auto-strike
- Sound effects across the site (`lib/audio/sound_fx.dart`): the hero slash, every clash in the duel, and the dojo. Browsers only allow audio after the visitor's first click, tap or key press; the speaker in the navbar toggles it
  

## 🖼 Screenshots


## 👨‍💻 Auther
Khalid Al-Saleh  khalid.alsaleh.dev@gmail.com
