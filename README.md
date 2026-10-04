# fit_pulse

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## ⚠️ Before a production build / deploy

Firebase App Check is set up for local testing with a **debug token**:

1. **Remove the debug token from `web/index.html`** — delete this line (and its comment):
   ```html
   <script>self.FIREBASE_APPCHECK_DEBUG_TOKEN = "…";</script>
   ```
   It is only for `localhost`. Anyone can read it from the page source and it
   would let them bypass App Check. Release builds also clear it at runtime as
   a safety net, but it must not be shipped.
2. Also delete that debug token in Firebase Console → App Check → Apps →
   `fit_pulse (web)` → ⋮ → **Manage debug tokens** if it was ever deployed.
3. Make sure the reCAPTCHA v3 **site key** is set in `lib/app_check_config.dart`
   (or pass `--dart-define=RECAPTCHA_SITE_KEY=...` to `flutter build web`).
   Release builds use `ReCaptchaV3Provider`; debug builds use the debug token.
