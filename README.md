# LinguaLearn 🌍

**A language-learning app for Somali speakers.** Learn vocabulary and grammar in
**English, Arabic or Turkish**, with every translation shown in **Somali**.

Built with **Flutter** and **Firebase** as part of the **CodeAlpha App Development
Internship** (Task: *Language Learning App*).

> **Af-Soomaali:** LinguaLearn waa app dadka Soomaaliga ku hadla ay ku bartaan
> Ingiriisi, Carabi iyo Turki. Turjumaad kasta waa Af-Soomaali.

## 📲 Try it

| | |
|---|---|
| 🌐 **Web app** (no install) | [languagelearnting.web.app/app](https://languagelearnting.web.app/app/) |
| 📱 **Android APK** | [Latest release](https://github.com/amiirofahad4-ai/CodeAlpha_LanguageLearningApp/releases/latest) → download `LinguaLearn.apk` under **Assets** |
| 🏠 **Download page** (with QR code) | [languagelearnting.web.app](https://languagelearnting.web.app) |

---

## ✅ CodeAlpha task requirements

| Requirement | How LinguaLearn meets it |
|---|---|
| Learn new words, phrases or sentences in a selected language | 3 languages, 60 words each, every word has an example sentence |
| Daily lessons or flashcards with translations and pronunciation | Daily lesson (5 words a day) **and** flip flashcards, Somali translation, phonetic spelling and text-to-speech |
| Quizzes or practice tests to check progress | 20-question quizzes with 4 question types, results and answer review |
| Clean, intuitive UI with categories like vocabulary and grammar | Material 3 design, light and dark mode, separate Vocabulary and Grammar sections |
| Store data locally or sync with a backend like Firebase | Firebase Auth + Cloud Firestore sync, with an offline copy on the phone |

---

## ✨ Features

### Learning
- **3 languages:** 🇬🇧 English, 🇸🇦 Arabic, 🇹🇷 Turkish (🇫🇷 French and 🇨🇳 Chinese are marked *Coming soon*)
- **3 levels:** Beginner (Bilow), Intermediate (Dhexe), Advanced (Sare)
- **6 vocabulary topics:** Family, Food, Travel, Numbers, Colors, Greetings (10 words each)
- **12 grammar lessons**, each with an explanation, a rule, examples and an exercise
  - English: pronouns, "to be", a/an, present simple, past simple, present perfect
  - Arabic: pronouns, the article ال, masculine & feminine
  - Turkish: plurals -ler/-lar, "to be" suffixes, present continuous -iyor
- **Pronunciation** with the device's text-to-speech voices
- **Flashcards** you flip and mark as known or still learning
- **Daily lesson** with 5 new words every day

### Quizzes
Questions are generated from the vocabulary, so every topic gets a quiz automatically.
- Multiple choice
- Listen and choose
- Fill in the blank
- Match pairs

Each quiz has 5 hearts, a results screen, confetti when you pass (70%+), and a review of your answers.

### Progress and motivation
- **XP** for learning words, correct answers, finished lessons and quizzes
- **Daily streak** and a **daily XP goal** (10 / 20 / 30 / 50)
- **Weekly XP chart**, learned words, finished lessons and average quiz score

### Account
- Sign up and log in with **email and password** or **Google**
- Forgot-password email
- Progress is saved to the cloud, so it follows you to a new phone

---

## 📱 Screens

| Area | Screens |
|---|---|
| Start | Splash, Onboarding |
| Account | Login, Register, Forgot password |
| Setup | Choose language, Choose level |
| Main tabs | Home, Learn, Quiz, Progress, Profile |
| Vocabulary | Topics, Word list, Word detail, Flashcards |
| Grammar | Lesson list, Lesson detail |
| Daily | Daily lesson |
| Quiz | Quiz hub, Quiz, Result, Review |

<!-- Add screenshots here, for example:
<p>
  <img src="screenshots/home.png" width="200">
  <img src="screenshots/flashcards.png" width="200">
  <img src="screenshots/quiz.png" width="200">
</p>
-->

---

## 🛠️ Built with

| Tool | Used for |
|---|---|
| [Flutter](https://flutter.dev) 3.44+ / Dart 3.12+ | The app (Android, Web) from one codebase |
| Material 3 | Design system, light and dark themes |
| Firebase Auth | Email/password and Google sign-in |
| Cloud Firestore | Syncing each user's progress |
| `provider` | State management |
| `go_router` | Navigation and sign-in redirects |
| `flutter_tts` | Pronunciation |
| `flip_card` | Flashcards |
| `fl_chart`, `percent_indicator` | Progress charts and rings |
| `confetti` | Celebration when a quiz is passed |
| `shared_preferences` | Settings and offline progress |
| `google_fonts` | Typography |

---

## 🏗️ Project structure

```
lib/
  main.dart              App entry: sets up Firebase, repositories, providers, router
  firebase_options.dart  Firebase config (made by FlutterFire CLI)
  core/                  Theme, colors, constants, routes, small utils
  models/                User, Language, Topic, Word, GrammarLesson,
                         QuizQuestion, Progress, AppSettings
  data/
    mock_data.dart       Languages, topics, words and grammar lessons
    quiz_generator.dart  Builds the 4 quiz question types from words
    repositories/        Interfaces + Firebase and local implementations
    services/            Text-to-speech
  providers/             AuthProvider, SettingsProvider, ProgressProvider
  screens/               One folder per screen
  widgets/               Reusable UI (cards, buttons, flashcards, quiz…)
test/                    Unit and screen smoke tests
firestore.rules          Firestore security rules
```

### Where data lives

| Data | Stored in |
|---|---|
| Accounts | Firebase Auth |
| Progress (XP, streak, learned words) | Cloud Firestore `users/{uid}`, plus an offline copy on the phone |
| Lessons, words, quizzes | Bundled in the app, so they work offline |
| Settings (theme, daily goal) | On the phone |

Screens only talk to repository interfaces (`AuthRepository`, `ContentRepository`,
`ProgressRepository`, `SettingsRepository`), so a data source can be swapped in
`main.dart` without changing any screen.

### Security
`firestore.rules` lets each signed-in user read and write **only their own** data.
Course content under `languages/` is read-only from the app.

---

## 🚀 Getting started

### Requirements
- Flutter 3.44+ (Dart 3.12+)
- Android Studio with an Android SDK, or Chrome for the web version

### Run
```bash
flutter pub get
flutter run              # pick a device or emulator
flutter run -d chrome    # web version
flutter test             # run the tests
```

### Build the APK
```bash
flutter build apk --release
```
The file is saved to `build/app/outputs/flutter-apk/app-release.apk`.

### Use your own Firebase project (optional)
The app is already connected to a Firebase project. To use your own:
1. Create a project in the [Firebase console](https://console.firebase.google.com) and turn on **Email/Password** and **Google** sign-in.
2. Create a **Cloud Firestore** database.
3. Run `flutterfire configure` to regenerate `lib/firebase_options.dart` and `android/app/google-services.json`.
4. Deploy the rules: `firebase deploy --only firestore:rules`.

---

## 📝 Notes
- Pronunciation uses the voices installed on the device. If a voice (for example Arabic) is missing, the speaker button shows a message.
- The daily reminder setting is saved, but notifications are not scheduled yet.
- To add a language, add its words to `lib/data/mock_data.dart` and list it in `contentLanguages`.
- Firebase is set up for Android and Web. iOS needs `flutterfire configure` first.

---

## 👤 Author

**Amiir Fahad**: CodeAlpha App Development Intern

<!-- Add your links:
- LinkedIn: https://www.linkedin.com/in/your-profile
- GitHub: https://github.com/your-username
-->

Made for the [CodeAlpha](https://www.codealpha.tech) internship.
