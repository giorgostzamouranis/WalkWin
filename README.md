# WalkWin

WalkWin is a Flutter-based mobile application that transforms your daily walks into a rewarding, engaging, and social experience. By tracking your steps, challenging yourself (or your friends), and earning in-app rewards, WalkWin motivates you to lead a healthier lifestyle while building a connected community.

---

## Table of Contents

- [Features](#features)
- [Technologies](#technologies)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)

---

## Features

- **Comprehensive Step Tracking**  
  - Monitors your daily, weekly, and monthly steps using an integrated pedometer and Firebase Firestore for real-time updates. ⏱️  
  - Automatically resets step counts based on the day, week, or month to keep your progress current.

- **Dynamic Challenges & Social Competitions**  
  - Complete app-created challenges to earn coins 💰—coins are automatically added to your rewards balance once your step goal is met.  
  - Create or participate in custom challenges with a friend or a group, adding a competitive and collaborative twist to your fitness journey. 🏆🤝

- **Social Engagement & Leaderboard**  
  - Easily add friends by scanning QR codes or by searching for usernames 🔍📱.  
  - Share your journey by posting stories and photos of your walks 📸✨.  
  - Compete with friends on a monthly leaderboard that tracks your steps, motivating you to climb to the top! 📊🔥

- **Reward System & In-App Store**  
  - Earn Walcoins with every step and redeem them for exclusive offers and coupons in the app’s store 🎟️🛍️.  
  - All transactions are securely managed with Firebase, ensuring real-time updates to your rewards balance.

- **Real-Time Data & Cloud Integration**  
  - Utilizes Firebase Authentication for secure sign-in/sign-up, Firestore for storing user data, and Firebase Storage for managing story photos and user avatars 🔒☁️.  
  - State management is streamlined using Provider for a smooth and responsive user experience.

---

## Technologies

- **Flutter:** For building the cross-platform mobile application.  
- **Firebase:**  
  - **Firestore:** Real-time database for tracking steps, challenges, and user data.  
  - **Authentication:** Secure sign-in and sign-up for users.  
  - **Storage:** Managing story photos, avatars, and other media.  
- **Provider:** For state management across the app.  
- **QR Code Libraries:** For scanning and generating QR codes.

---

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/walkwin.git
   cd walkwin
   
2. **Install Dependencies:**

   ```bash
   flutter pub get
3. **Firebase Setup:**

   - Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Add the necessary Firebase configuration files to your project:
     - For Android: `google-services.json`
     - For iOS: `GoogleService-Info.plist`
   - Update the `Firebase.initializeApp()` options in the code if running on the web.
4. **Run the App:**

   Launch the app on your preferred device or emulator:

   ```bash
   flutter run
## Usage

- **Step Tracking:**  
  When you sign in, WalkWin starts tracking your daily, weekly, and monthly steps using a built-in pedometer, with data updated in real time via Firebase Firestore.

- **Challenges:**  
  Complete pre-set challenges to automatically earn coins, or create/join custom challenges with friends or groups to compete and boost your motivation.

- **Social Features:**  
  - **Friend Management:** Add friends quickly by scanning QR codes or by searching for usernames.  
  - **Stories:** Post stories and photos of your walks to share your journey and inspire others.  
  - **Leaderboard:** Check out the monthly leaderboard to see how you rank against your friends.

- **Rewards:**  
  Earn Walcoins with every step you take and redeem them in the in-app store for exclusive offers and coupons.
## Credits

WalkWin was developed by **https://github.com/giorgostzamouranis** and my friend **https://github.com/NikosK10**.
