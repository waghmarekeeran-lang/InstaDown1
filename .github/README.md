# InstaDown — Social Media Video Downloader

Built with Flutter · Powered by RapidAPI

---

## Getting the APK (3 options)

---

### ✅ Option A — GitHub Actions (no Flutter needed, recommended)

1. Create a free GitHub account at github.com
2. Create a new **private** repository
3. Upload this entire project folder
4. Go to **Settings → Secrets and variables → Actions → New repository secret**
   - Name: `RAPIDAPI_KEY`
   - Value: your key from rapidapi.com
5. Go to **Actions → Build InstaDown APK → Run workflow**
6. Wait ~5 min → click the run → **Artifacts → InstaDown-release-apk → Download**
7. Unzip → install `app-release.apk` on your Android phone

> Enable "Install from unknown sources" on your phone:  
> Settings → Security → Install unknown apps → allow your file manager

---

### Option B — Local build (Flutter installed)

```bash
# 1. Install Flutter: https://flutter.dev/docs/get-started/install

# 2. Create the project scaffold
flutter create --org com.instadown --project-name instadown .

# 3. Replace generated lib/ with the provided lib/
# 4. Replace pubspec.yaml with the provided one

# 5. Create .env with your RapidAPI key
echo "RAPIDAPI_KEY=your_actual_key_here" > .env

# 6. Get dependencies
flutter pub get

# 7. Build APK
flutter build apk --release

# APK is at: build/app/outputs/flutter-apk/app-release.apk
```

---

### Option C — Codemagic (online build)

1. Go to codemagic.io → Sign in with GitHub
2. Connect your repository
3. Add RAPIDAPI_KEY as an environment variable
4. Start a build → download APK from build artifacts

---

## RapidAPI Setup

1. Sign up at **rapidapi.com**
2. Search for **"All Social Media Video Downloader"** by keepsaveitapi
3. Subscribe (free tier: 100 requests/month)
4. Copy your key from the **Code Snippets** panel
5. Paste it into `.env`:
   ```
   RAPIDAPI_KEY=abc123yourkey
   ```

---

## Project Structure

```
lib/
  main.dart                    ← App entry, Hive + dotenv init
  theme/app_colors.dart        ← Brand colors
  models/video_info.dart       ← API response model
  services/
    downloader_service.dart    ← RapidAPI HTTP call
    file_download_service.dart ← Dio file download + progress
    hive_service.dart          ← Local download history
  widgets/insta_logo.dart      ← Custom INSTA D▼WN logo
  screens/
    home_screen.dart           ← URL input screen
    app_menu_screen.dart       ← Hamburger menu
    download_progress_screen.dart ← Fetch + download + progress
    downloads_screen.dart      ← History list + Open With sheet
    video_player_screen.dart   ← Full-screen video player
    how_to_download_screen.dart ← Tutorial card

android/
  app/src/main/
    AndroidManifest.xml        ← Internet + storage permissions
    kotlin/com/instadown/app/
      MainActivity.kt

.github/workflows/build_apk.yml  ← CI/CD — builds APK on push

pubspec.yaml                     ← All dependencies
.env                             ← Your RAPIDAPI_KEY (not committed)
```

---

## Supported Platforms

Instagram Reels · TikTok · YouTube Shorts · Facebook Reels  
Twitter/X · Pinterest · Snapchat · Dailymotion · Vimeo · 30+ more

---

## Dependencies

| Package | Use |
|---|---|
| `http` | RapidAPI HTTP calls |
| `dio` | File download with progress |
| `path_provider` | Device storage path |
| `hive_flutter` | Local download history |
| `video_player` | In-app video playback |
| `flutter_dotenv` | Secure API key loading |
| `cached_network_image` | Thumbnail caching |
| `permission_handler` | Runtime storage permissions |

---

© 2025 Monarch Inc. All rights reserved.
