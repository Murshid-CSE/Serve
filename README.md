# Community Care Hub 🌟

One Platform. One Community. One Coordinated Workflow. 

**Community Care Hub** is a premium, production-ready Flutter mobile application designed to coordinate local humanitarian welfare workflows. By integrating surplus food distribution, blood donation matching, volunteer task coordination, and localized real-time emergency response, the platform empowers neighborhoods to act dynamically and coordinate actions immediately.

---

## 📱 Core Feature Modules

### 1. 🍱 Surplus Food Rescue
* **Minimize Waste**: Local donors (restaurants, events, households) can publish surplus food listings with quantity, category, and expiration time.
* **Instant Rescue**: Recipients or volunteers can claim available listings for distribution.
* **Proximity Filters**: Location-based radius filtering (2km to 25km) lists nearby rescues first.

### 2. 🩸 Blood Donation Network
* **Rapid Response**: Request blood matching by specifying patient name, blood group, hospital location, and urgency.
* **Donor Directory**: Users register as donors with their blood group, location coordinates, and availability status.
* **Smart Compatibility**: Implements compatibility matrices to filter matches (e.g., O- as a universal donor, AB+ as a universal recipient).

### 3. 🤝 Volunteer Missions
* **Community Actions**: Create cleanup drives, distribution events, or rescue operations.
* **Impact & Trust Scores**: Earn impact score points on successful completion. Track trust index using the reliability rating ring (respecting the 90-day donation cooldown).
* **FAB Direct Access**: Create new missions directly from the homepage.

### 4. 🚨 Real-time Emergency Response
* **SOS Broadcasts**: Instantly report critical incidents with urgency levels (`critical`, `warning`, `info`).
* **Geocoded Map Location**: Auto-geocoding displays physical addresses from coordinates.
* **Dialer Integration**: Fast-dial support for emergency hotlines (112).

### 5. 🛠️ Admin Console
* **Detailed User & Role Management**: Suspend users, promote/demote roles (Admin, Volunteer, Donor, Both) with search and deletion filters.
* **Detailed Contribution Auditing**: Verify and manage active food, blood, emergency, or volunteer tasks, with bulk approval/deletion options.

---

## 🎨 Premium Design System

* **Theme Toggles**: Responsive light and dark modes adaptive to system brightness.
* **Material 3**: Clean grids, card systems, and modular custom painters.
* **Glassmorphism & Gradients**: Harmonies of curated primary reds, teal accents, and warm amber gradients.
* **Animated Feedback**: Shimmer placeholders, tween animations for scores, and custom canvas-drawn reliability index indicators.

---

## 🧱 Clean Architecture (SOLID)

The project strictly implements Uncle Bob's **Clean Architecture**, decoupled into three solid layers:

```
lib/
├── core/                   # Common constants, themes, widgets, utilities
│   ├── constants/          # App colors, firebase collections, string constants
│   ├── extensions/         # Context, DateTime, String helper extensions
│   ├── utils/              # Geolocator, image compression, validators
│   └── widgets/            # Reusable buttons, cards, empty states, status chips
│
├── navigation/             # Routing configuration (GoRouter & shell navigation)
│
└── features/               # Decoupled Feature Modules (auth, food, blood, volunteer, emergency, profile, admin)
    ├── data/               # Data Layer: datasources, repositories implementations
    ├── domain/             # Domain Layer: business entities, usecases, repo interfaces
    └── presentation/       # Presentation Layer: Riverpod providers, widgets, screens
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK `^3.12.0` (with Dart `^3.12.0`)
* Java JDK 17
* Firebase project console setup.

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/Murshid-CSE/Tailor-Management-System
   ```
2. Resolve Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the static analyzer:
   ```bash
   flutter analyze
   ```
4. Run all unit and widget tests:
   ```bash
   flutter test
   ```
5. Run the application:
   ```bash
   flutter run
   ```

---

## 🧪 Testing Coverage

The codebase includes comprehensive unit, domain, and validation tests in `test/unit_test.dart`.
* Run tests: `flutter test`
* Covers: Email/phone validation constraints, distance calculation Haversine formula, blood compatibility matrices, geohash ranges, and user model serializations.
