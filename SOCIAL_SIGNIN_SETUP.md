# Social Sign-In Setup (Google + Facebook)

Project: `rizzmusic-ff756`  
Flutter app package/bundle: `com.example.rizzmusicapp`

This app now supports:
- Email/password sign-in (`Firebase Auth`)
- Google sign-in
- Facebook sign-in

## 1. Firebase Authentication Providers

1. Open Firebase Console -> `Authentication` -> `Sign-in method`.
2. Enable `Google`.
3. Enable `Facebook`.
4. For Facebook provider, enter:
- Facebook App ID
- Facebook App Secret
5. Save changes.

## 2. Android Setup

### 2.1 Google (Required)

1. Firebase Console -> `Project settings` -> Android app `com.example.rizzmusicapp`.
2. Add SHA-1 and SHA-256 fingerprints.
3. Download fresh `google-services.json`.
4. Replace file:
- `android/app/google-services.json`
5. Verify `oauth_client` is not empty in that JSON.

### 2.2 Facebook (Required)

In Facebook Developers -> your app -> Android settings:
- Package name: `com.example.rizzmusicapp`
- Default class name: `com.example.rizzmusicapp.MainActivity`
- Key hashes: add debug and release key hashes

Generate key hash (debug):

```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore \
| openssl sha1 -binary | openssl base64
```

Project files are already prepared with placeholders:

- `android/app/src/main/res/values/strings.xml`
- `android/app/src/main/AndroidManifest.xml`

Now replace placeholder values in `strings.xml`:

1. Set real values:
```xml
<resources>
    <string name="facebook_app_id">REAL_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbREAL_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">REAL_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

2. `AndroidManifest.xml` entries are already added. Verify these exist:
```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>

<activity android:name="com.facebook.FacebookActivity" android:configChanges=
    "keyboard|keyboardHidden|screenLayout|screenSize|orientation" android:label="@string/app_name" />
<activity android:name="com.facebook.CustomTabActivity" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="@string/fb_login_protocol_scheme"/>
    </intent-filter>
</activity>
```

## 3. iOS Setup

### 3.1 Google (Required)

1. Download latest `GoogleService-Info.plist` from Firebase iOS app settings.
2. Replace:
- `ios/Runner/GoogleService-Info.plist`
3. Ensure the plist has:
- `CLIENT_ID`
- `REVERSED_CLIENT_ID`
4. In `ios/Runner/Info.plist`, add URL scheme = `REVERSED_CLIENT_ID`.

### 3.2 Facebook (Required)

In Facebook Developers -> iOS settings:
- Bundle ID: `com.example.rizzmusicapp`

`ios/Runner/Info.plist` is already prepared with placeholder entries.

Replace these placeholders with real values:
```xml
<key>FacebookAppID</key>
<string>REAL_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>REAL_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>REAL_FACEBOOK_APP_NAME</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbREAL_FACEBOOK_APP_ID</string>
      <string>com.googleusercontent.apps.1097226990560-gn232sovgrhdfpg1fhsn32ur4a9mqf12</string>
    </array>
  </dict>
</array>
```

## 4. Web Setup

### 4.1 Firebase Authorized Domains

Firebase Console -> `Authentication` -> `Settings` -> `Authorized domains`:
- `localhost`
- `127.0.0.1`
- your production domain

### 4.2 Google

No extra web file edits required if Firebase web config is correct.

### 4.3 Facebook

Set Facebook App ID at runtime:

```bash
flutter run -d chrome --dart-define=FACEBOOK_APP_ID=YOUR_FACEBOOK_APP_ID
```

Also configure Facebook Valid OAuth Redirect URIs with Firebase handler URL:

`https://rizzmusic-ff756.firebaseapp.com/__/auth/handler`

## 5. Required Dart Defines

Google iOS client ID (optional override; default is already set in code):

```bash
--dart-define=GOOGLE_IOS_CLIENT_ID=1097226990560-gn232sovgrhdfpg1fhsn32ur4a9mqf12.apps.googleusercontent.com
```

Facebook web app ID:

```bash
--dart-define=FACEBOOK_APP_ID=YOUR_FACEBOOK_APP_ID
```

## 6. Final Verification

1. `flutter clean`
2. `flutter pub get`
3. Test Email login.
4. Test Google login on Android/iOS/Web.
5. Test Facebook login on Android/iOS/Web.
6. Confirm user appears in Firebase Auth users list.
