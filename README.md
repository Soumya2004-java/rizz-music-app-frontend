# rizzmusicapp

Flutter music app with cloud-ready song listing and streaming playback.

## Cloud storage setup (music for all users)

1. Upload your `.mp3` files and cover images to any cloud storage (Firebase Storage, AWS S3, GCP Storage, Cloudinary).
2. Create a public JSON catalog (example: [`cloud_songs_example.json`](cloud_songs_example.json)) with:
   - `id`
   - `title`
   - `artist`
   - `album`
   - `audioUrl` (public HTTPS URL to the music file)
   - `imageUrl` (optional cover image URL)
   - `durationSeconds` (optional)
3. Host that JSON file at a public URL.
4. Run the app with:

```bash
flutter run --dart-define=SONGS_CATALOG_URL=https://your-domain.com/songs.json
```

If `SONGS_CATALOG_URL` is not provided, app falls back to the existing backend API (`API_BASE_URL` + `/songs`).

## Optional backend URL override

```bash
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com
```
