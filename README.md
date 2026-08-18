# 📱 MASS APP — Production Mobile Apps Suite

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Play%20Store-green.svg?style=flat)]()
[![Author](https://img.shields.io/badge/Author-Chandan%20Singh-blueviolet.svg?style=flat)](https://github.com/SCHANDAN996)

A suite of production-ready, lightweight, offline-first **Flutter & Android Mobile Applications** specifically engineered for Bharat users — including Land Measurement Tools (**Jameen Napi**), Agritech Calculators (**Pro Kisan**), Construction Utilities (**Mistri Calculator**), and English Speaking training apps.

---

## 🌟 Flagship Production Applications

### 1️⃣ 🗺️ Jameen Napi (जमीन नापी — GPS Land Measurement)
* **Description:** Real-time GPS and Polygon Land Area Measurement application for farmers, Patwaris, and surveyors.
* **Core Capabilities:**
  * GPS Walk-around boundary perimeter & area measurement.
  * Tap-to-draw cadastral polygon on Google Maps & Satellite imagery.
  * Instant conversion between **Bigha (Pucca/Kaccha), Biswa, Dhur, Acre, Hectare, Square Meter & Square Feet**.
  * PDF Land Survey Report generation with coordinate stamps.
* **Stack:** Flutter, Google Maps SDK, Geolocation, PDF generation, Hive offline storage.

### 2️⃣ 🌾 Pro Kisan & Kisan Calculator (किसान कैलकुलेटर)
* **Description:** Comprehensive agricultural business calculation engine for crop yield, fertilizer estimation, and harvest economics.
* **Core Capabilities:**
  * Fertilizer Dosage calculator (Urea, DAP, MOP per Bigha/Acre).
  * Crop Seed Rate & Harvest profit estimator.
  * Mandi Rate & Weighbridge deduction calculator.

---

## 📱 Complete Application Portfolio & Roadmap

| # | Application | Domain & Engine | Target Audience | Key Monetization |
| :---: | :--- | :--- | :--- | :--- |
| **01** | 🧱 **Mistri Calculator** | Construction & Material Engine | Contractors, Masons, Builders | Interstitial Ads & Pro Tools |
| **02** | 🗣️ **Interview English** | Speech & Voice Practice Engine | Job Seekers, Freshers | Rewarded Unlock |
| **03** | 🥛 **Dudh ka Hisab** | Daily Dairy Ledger & FAT/SNF | Dairy Farmers, Milk Centers | Daily Active Use Ads |
| **04** | 👷 **Hajiri Majdoori Hisab** | Daily Wage & Attendance Tracker | Labor Contractors & Workers | Paid Cloud Backup |
| **05** | 🐄 **Pashu Calculator** | Cattle Feed, Milk Yield & Health | Dairy & Livestock Owners | Niche Agritech Ads |
| **06** | 🧪 **Khaad-Beej Calculator**| Fertilizer & Seed Optimizer | Farmers & Fertilizer Dealers| Banner & Interstitials |
| **07** | 🚖 **English for Drivers** | Voice Phrases for Cab/Delivery | Commercial Drivers | Voice Pack Unlock |
| **08** | 🏪 **English for Shopkeepers**| Retail & Customer English Dialogs| Shop Owners, Retailers | Voice Pack Unlock |
| **09** | 💰 **Bachat Gat SHG Hisab** | Micro-Finance & Self-Help Group | Rural SHGs & Women Groups | Group Subscription |
| **10** | 🚛 **Truck Bhada Hisab** | Freight, Toll, Mileage & Diesel | Truck Drivers & Transporters | Utility Subscription |
| **11** | ✂️ **Silai Master** | Tailoring Measurements & Ledger | Tailors & Boutique Owners | Measurement Cloud Backup |

---

## 🏗️ Architecture & Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│                    MASS APP ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────┤
│  1. 100% Offline-First: SQLite / Hive local database        │
│  2. Hindi-First UI/UX: Intuitive Devanagari & Hinglish      │
│  3. Lightweight Bundle: < 20MB release APK size             │
│  4. Zero Barrier: No mandatory login required               │
│  5. Reusable Component Engines (Kisan Calc, SpeakEasy, DB)  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Building & Running Locally

### Prerequisites
* Flutter SDK (3.22+)
* Android Studio / Android SDK (API 34)

### Commands
```bash
# 1. Navigate to any app directory (e.g. Jameen Napi)
cd "Jameen Napi"

# 2. Get packages
flutter pub get

# 3. Run in Debug Mode
flutter run

# 4. Build Optimized Release APK
flutter build apk --release --split-per-abi
```

---

## 👤 Author & Maintainer
* **Chandan Singh** — [@SCHANDAN996](https://github.com/SCHANDAN996)
* 📬 **Contact:** [all.chandansingh@gmail.com](mailto:all.chandansingh@gmail.com)
