# 🎟️ Event Booking App - `event_app`

A full-featured Flutter application for **planning, searching, and booking events** with venue management, ticket generation, calendar integration, and Firebase-based feedback and authentication.

---

## 📲 Overview

This app empowers users to:

- 🔍 Discover and filter events by location, date, and type
- 🏛️ Reserve venues for hosting events
- 🎫 Book tickets and manage event entries
- 📆 Use calendar UI for event schedules
- 📝 Submit feedback with Firebase Auth integration

---

## 🚀 Key Features

| Feature                        | Description |
|-------------------------------|-------------|
| 🔍 Event Search & Filter       | Advanced search by category, date, and venue |
| 🏛️ Venue Booking               | Secure venue booking with validation and availability check |
| 🎫 Ticket Generation           | Instant ticket creation with unique IDs |
| 📆 Calendar UI & Animations    | Schedule view with Flutter animations |
| 🔐 Firebase Authentication     | Email/password login and secure access |
| 📋 Feedback Form               | Submit experience feedback stored in Firestore |
| 🌐 API Integration             | REST API fetch for live events (mock/dynamic) |

---

## 📂 Project Structure

```plaintext
lib/
├── main.dart
├── models/
│   ├── event.dart
│   └── venue.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── booking_screen.dart
│   ├── ticket_screen.dart
│   └── feedback_screen.dart
├── widgets/
│   ├── event_card.dart
│   └── custom_form.dart
├── services/
│   ├── api_service.dart
│   └── firebase_service.dart
## 🛠️ Getting Started

### ✅ Prerequisites

- Flutter SDK (latest stable version)
- Dart
- Firebase project (Firestore + Authentication enabled)
- Android Studio / VS Code

---

### 📦 Installation Steps

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/your-username/event_app.git
   cd event_app
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Configure Firebase**

   - **Android**:
     - Go to Firebase Console and create a new project.
     - Register your Android app with the correct package name.
     - Download the \`google-services.json\` file.
     - Place it in the \`android/app/\` directory.

   - **iOS**:
     - Register your iOS app in Firebase.
     - Download the \`GoogleService-Info.plist\` file.
     - Place it in the \`ios/Runner/\` directory.
     - Open \`ios/Runner.xcworkspace\` in Xcode and add the plist if needed.

4. **Enable Firebase Services**

   - Go to **Firebase Console > Build > Authentication** → Enable **Email/Password** sign-in method.
   - Go to **Firestore Database** → Create a new database in **test mode** or with proper rules.

5. **Run the app**
   \`\`\`bash
   flutter run
   \`\`\`

---

### ❗ Troubleshooting Tips

- 🔁 If Firebase doesn’t initialize correctly, double-check config file paths.
- 📱 If Android build fails, ensure \`minSdkVersion\` is set to **21 or higher** in \`android/app/build.gradle\`.
- 🍎 For iOS:
   \`\`\`bash
   cd ios
   pod install
   cd ..
   \`\`\`

---

## 📸 Screenshots

### 🏠 Home Screen  
![Home Screen](assets/screenshots/Home_screen.png)

---

### 🔐 Login Screen  
![Login Screen](assets/screenshots/Login_screen.png)

---

### 📝 Signup Screen  
![Signup Screen](assets/screenshots/Signup_screen.png)

---

### 🎫 Ticket Booked Confirmation  
![Ticket Booked](assets/screenshots/Ticket_booked.png)

---

### 🎟️ Ticket Display Screen  
![Ticket Screen](assets/screenshots/Ticket_screen.png)

---

## 🙌 Contributions

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
EOF
