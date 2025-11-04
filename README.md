# 🛰️ Location Tracking App

A Flutter-based **real-time location tracker** that monitors user movement, stores it locally using **SQLite**, and syncs the data automatically to **Firebase Cloud Firestore** when online.
The app also draws both **live current location routes** and **stored session routes** on Google Maps — offering a complete history of user movements with dynamic dark/light theme support.

---

## 🚀 Features

* 📍 **Real-time Location Tracking**
  Continuously tracks the user’s current location and draws the live route on Google Maps.

* 💾 **Offline Storage (SQLite)**
  All tracked sessions are saved locally in SQLite when offline.

* ☁️ **Cloud Sync (Firebase Firestore)**
  Automatically syncs unsynced session data once internet connectivity is detected.

* 🗺️ **Stored Session Visualization**
  View saved sessions with their exact routes, start & end markers, and path on Google Maps in the **Session Detail Screen**.

* 🎨 **Dynamic Theme Support**
  The app dynamically switches between dark and light themes based on the device’s settings.

* 🔄 **Smart Resource Handling**
  Timers, streams, and map controllers are safely disposed of when tracking stops.

* 🔐 **Connectivity-Aware Syncing**
  Uses **Connectivity Plus** to ensure data sync happens only when the device has an active network.

---

## 🧩 Tech Stack

| Technology             | Purpose                       |
| ---------------------- | ----------------------------- |
| **Flutter (v3.27.1)**  | Cross-platform framework      |
| **Dart**               | Core language                 |
| **Google Maps SDK**    | Map rendering & route drawing |
| **Geolocator**         | Real-time location stream     |
| **Firebase Firestore** | Cloud storage & data sync     |
| **SQLite (sqflite)**   | Local data persistence        |
| **Provider**           | State management              |
| **Connectivity Plus**  | Internet connection detection |

---

## 📱 Screens Overview

### 🏠 Home Screen

* Displays a list of all sessions with status indicators (Synced / Pending).
* Option to start a new tracking session.

### 🚶‍♂️ Tracking Screen

* Shows **live location updates** on Google Maps.
* Draws your current movement path in real-time.
* Saves all location points locally during tracking.

### 🗺️ Session Detail Screen

* Displays the full **stored route path** for any completed session.
* Highlights start and end markers on Google Maps.
* Shows:

  * Session ID
  * Start and End Time
  * Distance (in kilometers)
  * Start & End Address (from Google Maps API)
  * Sync status

### 🌗 Dynamic Theme

* Auto-switch between light and dark themes based on system preference.

---

## ⚙️ Setup & Installation

1. **Clone the repository:**

   ```bash
   git clone[https://github.com/your-username/trackme.git](https://github.com/soneev/trackme.git)
   cd trackme
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Add Google Maps API Key:**

   * Open: `android/app/src/main/AndroidManifest.xml`
   * Add your key:

     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE"/>
     ```

4. **Configure Firebase:**

   * Add `google-services.json` (for Android)
   * Add `GoogleService-Info.plist` (for iOS)

5. **Run the app:**

   ```bash
   flutter run
   ```

---

## 📏 Distance & Address Calculation

* The app calculates **total traveled distance in kilometers** using latitude and longitude pairs.
* Uses **Google Geocoding API** to fetch the **start and end address** based on coordinates.
* Distance and address details are displayed with relevant icons in the session summary card.

---

## 💡 Developer Notes

* Uses **Provider** for managing tracking and session data efficiently.
* Data is synced automatically once network connectivity is restored.
* Map bounds auto-adjust to display the **entire route** without manual zooming.
* Users can still **zoom and pan** freely on the map for detailed viewing.
* Proper cleanup ensures no memory leaks during navigation or session end.

---

## 🧾 License

This project is licensed under the **MIT License** — you’re free to use, modify, and distribute it with attribution.

---

**Developed by:** [Soneev]
**Flutter Version:** 3.27.1
**Databases:** SQLite + Firebase
**Last Updated:** November 2025
