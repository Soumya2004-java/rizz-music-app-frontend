# rizzmusicapp

Flutter music app with Firebase-powered streaming playback, profile, and settings.

## Firebase schema

### `songs` (required)

Per document:

- `title` (string)
- `artist` (string)
- `album` (string)
- `audioPath` (string, pattern `music/{artist-slug}/{song-slug}.mp3`) or `audioUrl`
- `imagePath` (string, pattern `covers/{artist-slug}/{song-slug}.jpg`) or `imageUrl`
- `durationSeconds` (number, optional)

### `playlists` (optional)

Per document:

- `name` (string)
- `description` (string, optional)
- `imageUrl` (string, optional)
- `songIds` (array of song document IDs)

### `users/{uid}` (required for profile/settings)

Fields used:

- `name`, `username`, `bio`, `membership`
- `favoriteGenre`, `favoriteArtist`, `location`
- `appSettings` (map):
  - `wifiOnlyDownloads`, `normalizeAudio`, `autoplay`, `crossfade`
  - `equalizerEnabled`, `pushNewReleases`, `pushRecommendations`
  - `privateSession`, `listeningActivityVisible`, `biometricLock`
  - `crossfadeSeconds`, `bassLevel`, `midLevel`, `trebleLevel`
  - `dolbyAtmos`, `highResMusic`, `equalizerPreset`, `theme`, `language`, `cacheLimit`

### `app_config/mobile` (optional, global app options)

Fields used:

- `membershipPlans`, `themes`, `languages`, `cacheLimits`
- `equalizerPresets`, `dolbyAtmosOptions`, `highResOptions`
- `reportProblemTypes`
- `helpFaqs` (array of objects: `question`, `answer`)
- `aboutAppName`, `aboutVersion`, `aboutDescription`

### `support_reports` (optional)

Submitted from Report Problem screen:

- `uid`, `email`, `type`, `message`, `status`, `createdAt`

## Firestore rules

This repo includes rules for:

- user-scoped read/write on `users/{uid}`
- authenticated read on `songs` and `app_config`
- authenticated create on `support_reports`

## Running

```bash
flutter pub get
flutter run
```

## Social sign-in setup

- `SOCIAL_SIGNIN_SETUP.md`
