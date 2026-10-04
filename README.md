# FitPulse 💪

FitPulse is a fitness tracker for the web built with Flutter and Firebase. It
combines guided workouts with an AI coach, a personalised weekly plan,
gamification, hydration and weight tracking, and a friends leaderboard. The
whole app uses a dark "neon HUD" design.

**🔗 Live app:** https://fitpulse-ccb08.web.app

---

## ✨ Features

- **AI Coach ("Pulse")**: a chat coach powered by Gemini through Firebase AI
  Logic. It knows your goal, level, body stats and recent workouts, streams its
  replies, offers suggestion chips, and declines medical questions. Chat history
  is saved per user.
- **Smart onboarding**: four animated questions (goal, height/weight, level,
  days per week) build a personalised weekly plan that shows up in the Planner
  and on Home.
- **XP, levels and badges**: earn XP from the time you actually exercise. There
  are 10 levels from *Beginner* to *Legend* and 10 badges (first workout,
  streaks, workout milestones, Early Bird, Hydration Hero…). A confetti popup
  celebrates each new badge.
- **Guided workouts**: a glowing circular timer with a "next up" preview.
  Minutes and calories come from time actually exercised; skipped exercises
  don't count. If you quit after at least a minute, the session is saved as a
  partial workout.
- **Exercise visuals**: two-frame movement images from
  [free-exercise-db](https://github.com/yuhonas/free-exercise-db), "How to do
  it" steps, and thumbnails throughout the app.
- **Water tracker**: an animated wave bottle. The daily goal comes from your
  body weight, and progress is stored per date.
- **Weight progress**: log your weight by date and set a goal weight. You get a
  gradient line chart, kg lost / to go, a progress ring and an editable history.
- **Friends leaderboard**: add friends with a 6-character invite code and
  compete on weekly XP with an animated top-3 podium. Friends only see a
  public card (name, avatar, level, XP).
- **Share card**: after a workout, export a summary card as a PNG, or share it
  with the Web Share API where the browser supports it.
- **In-app notifications**: a notification center with unread badges, mark all
  read and swipe to delete. Smart alerts cover streak-at-risk, workout and water
  reminders, weight logging, weekly goal, badges and leaderboard weeks, and they
  slide in as glass banners while the app is open.
- **Also included**: workout history, progress charts, BMI gauge, workout
  planner, custom workouts, exercise search, DiceBear avatars, a neon intro with
  Ken Burns photos, and guest mode.

## 🛠 Tech stack

| Area | Technology |
|------|------------|
| App | Flutter (web), Provider, `flutter_animate`, `fl_chart`, Google Fonts |
| Auth | Firebase Authentication (email/password) |
| Data | Cloud Firestore with security rules |
| AI | Firebase AI Logic (Gemini Developer API) |
| Hosting | Firebase Hosting |

## 🗂 Data model (Firestore)

```
users/{uid}                    profile, workouts, plan, water, badges (private)
users/{uid}/weights/{id}       weight entries
users/{uid}/notifications/{id} in-app notifications
users/{uid}/coachChats/{id}    AI coach conversation
users/{uid}/meta/notifications reminder settings
publicProfiles/{uid}           leaderboard card (owner + friends only)
inviteCodes/{code}             invite code → uid lookup
```

## 🚀 Run locally

Prerequisites: the Flutter SDK (3.35+) and the Firebase CLI.

```bash
git clone https://github.com/Gul-e-Narjis/FitPulse.git
cd FitPulse
flutter pub get
flutter run -d chrome
```

To use your own Firebase project instead, run `flutterfire configure` and then
enable these in the Firebase console:

- Email/Password sign-in
- Cloud Firestore
- Firebase AI Logic (Gemini Developer API)

## 🌐 Deploy

```bash
flutter build web --release
firebase deploy --only "hosting,firestore:rules" --project fitpulse-ccb08
```

---

Made by **Gul-e-Narjis**.
