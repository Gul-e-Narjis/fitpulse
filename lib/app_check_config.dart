// reCAPTCHA v3 *site* key for Firebase App Check (web, release builds).
// The site key is public by design; never put the secret key here.
// Can also be supplied at build time:
//   flutter build web --dart-define=RECAPTCHA_SITE_KEY=your-key
const recaptchaSiteKey = String.fromEnvironment(
  'RECAPTCHA_SITE_KEY',
  defaultValue: '',
);
