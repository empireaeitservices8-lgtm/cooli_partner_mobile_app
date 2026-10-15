# COOLI PARTNER

> **WORK. MOVE. EARN.**  
> The ultimate driver, delivery partner, and commercial fleet marketplace application.

---

## 1. Project Overview

**COOLI PARTNER** is a Flutter mobile application built exclusively for drivers, logistics delivery partners, mini-truck operators, and commercial fleet owners. It serves as an all-in-one partner marketplace across four core pillars:

1. **Ride Mobility:** Driver-side ride hailing with turn-by-turn state machines, pickup/destination waypoints, and transparent fare breakdowns.
2. **Porter Intra-City Logistics:** Parcel, box, and cargo delivery with load weight specs, sender/receiver contacts, and stage-by-stage progression.
3. **Truck & Freight Marketplace:** Inter-city and heavy freight load board with direct acceptance, custom bidding, and customer counter-offer negotiation.
4. **Partner Operations:** Real-time earnings dashboard with interactive charts, multi-vehicle fleet registry, compliance document management, safety SOS, bank account settlement, and support center.

### 4 Partner User Categories in One Unified App:
1. 🚖 **Ride Driver** (*Vishnu Prasad*): Passenger cabs, taxis, auto-rickshaw hailing, and city transfers.
2. 🛵 **Delivery Partner** (*Anandhu K.*): Two-wheeler couriers, express parcel dispatch, food & quick commerce.
3. 📦 **Porter Partner** (*Rahul Kumar*): Mini-trucks (Tata Ace), intra-city goods loading, and shifting.
4. 🚛 **Commercial Truck Owner / Transporter** (*Arun Raj*): Heavy freight trucks (Ashok Leyland 16T), multi-ton freight loads & bidding.

*Partners can register directly for any of these 4 categories, or switch between all 4 personas on-the-fly using the interactive **Partner Persona Switcher** on the Home dashboard and Profile screen.*

---

## 2. Design System & Brand Identity

COOLI PARTNER uses a custom, modern Indian logistics visual language with a **Map-First, Driver-Centric, Card-Based** aesthetic:

- **Primary Colors:**
  - `AppColors.primaryBlue`: `#2563EB` (Cobalt / Royal Blue)
  - `AppColors.darkBlue`: `#1D4ED8` (Deep Blue)
  - `AppColors.secondaryPurple`: `#6366F1` (Indigo Accent)
  - `AppColors.accentOrange`: `#F59E0B` (Amber / Warning)
  - `AppColors.background`: `#F5F8FF` (Soft Lavender Background)
  - `AppColors.surface`: `#FFFFFF` (Elevated White Cards)
- **Typography:**
  - Modern Google Font (`Inter` / `Poppins`) with high-readability number displays for distance, fares, and earnings.
- **Real Image Assets Catalog:**
  - `assets/images/onboarding_driver.jpg`: Commercial partner driver standing with dispatch delivery vehicle.
  - `assets/images/onboarding_truck.jpg`: Heavy logistics highway freight transport carrier.
  - `assets/images/onboarding_earnings.jpg`: Digital wallet and daily earnings growth visualization.
  - `assets/images/driver_avatar.jpg`: Authentic partner driver portrait avatar (Header, Profile & Active Rides).
  - `assets/images/mini_truck.jpg`: Tata Ace commercial mini-truck photography.
  - `assets/images/pickup_truck.jpg`: Mahindra Bolero commercial pickup carrier photography.
  - `assets/images/heavy_truck.jpg`: Multi-axle commercial freight logistics truck.
  - `assets/images/load_apples.jpg`: Real apple crates agriculture freight cargo shipment.
  - `assets/images/load_electronics.jpg`: Warehouse electronics parcel & cargo packages.
- **Spacing & Radius:**
  - Card radius: 16–22px, Input radius: 14–18px, generous touch targets for safe one-handed mobile usage.

---

## 3. Architecture & Code Structure

The project follows a **Feature-First Clean Architecture** powered by **Flutter Riverpod** and **GoRouter**:

```text
lib/
├── core/
│   ├── routes/          # GoRouter routes and path constants (AppRoutes)
│   ├── theme/           # AppColors, AppTextStyles, AppSpacing, AppTheme
│   └── widgets/         # 25+ reusable design system components:
│                        #   - AppScaffold, AppHeader, BackHeader, ProfileHeader
│                        #   - CooliPrimaryButton, CooliSecondaryButton, CooliDangerButton
│                        #   - CooliTextField, OtpField, SearchField
│                        #   - StatusBadge, OnlineStatusToggle, RatingWidget
│                        #   - CooliCard, StatCard, InfoRow, PriceRow
│                        #   - PartnerMap (Live fallback / vector placeholder)
│                        #   - TimelineWidget, VehicleIllustration, TruckIllustration
├── features/
│   ├── auth/            # Splash, Onboarding, Login, OTP, Partner Registration Wizard
│   ├── home/            # Shell with floating BottomNav, Driver Home Dashboard
│   ├── jobs/            # Available/Active/History Jobs, Incoming Job Request Modal
│   ├── ride/            # Active Ride State Machine, Ride Completed, Driver Rating
│   ├── porter/          # Porter Cargo Details & Pickup-to-Delivery Timeline
│   ├── truck/           # Freight Load Board, Load Details, Bidding & Counter Offers
│   ├── earnings/        # Animated Stats, Earnings Chart (fl_chart), Transactions
│   ├── vehicles/        # Fleet Management, Vehicle Details, Add Vehicle Wizard
│   ├── documents/       # Compliance Verification, Document Upload & Previews
│   ├── profile/         # Driver Profile, Bank Account (masked), Driver Ratings
│   ├── notifications/   # Segmented Notifications (Jobs, Payments, Docs, Safety)
│   ├── support/         # Help Center, FAQ Categories, Ticket Management
│   └── safety/          # Dedicated Safety Center, Confirmed SOS, Emergency Contacts
├── models/              # Strongly typed Dart models & enums (Partner, Job, Ride, Bid, etc.)
├── providers/           # Riverpod StateNotifier providers & domain state management
├── repositories/        # Repository contracts & mock implementations
├── services/            # Mock dataset (realistic Indian routes & fares) & LocationService
└── main.dart            # ProviderScope entrypoint
```

---

## 4. Getting Started & Installation

### Prerequisites
- **Flutter SDK:** `>= 3.3.0 < 4.0.0`
- **Dart SDK:** `>= 3.3.0 < 4.0.0`
- Android Studio / VS Code with Flutter extension
- Windows / macOS / Linux development environment

### Quick Setup

```bash
# 1. Clone or navigate to the repository
cd cooli_partner

# 2. Get dependencies
flutter pub get

# 3. Verify static analysis (0 errors, 0 warnings)
flutter analyze

# 4. Run automated unit & widget test suite
flutter test

# 5. Run the application (runs immediately with mock mode enabled)
flutter run
```

---

## 5. Mock Mode (Zero-Config Launch)

The application is architected to launch and operate **out of the box** without any Firebase credentials or Google Maps API keys:

- **Mock Authentication:**
  - Enter any valid 10-digit Indian mobile number (e.g., `9876543210`).
  - Enter OTP: `123456` (configured in `MockAuthRepository`).
- **Mock Datasets:**
  - Realistic locations: Kochi, Ernakulam, Kakkanad, Thrissur, Aluva, Angamaly.
  - Realistic vehicles: Tata Ace, Mahindra Bolero Pickup, Ashok Leyland Dost, Bajaj Pulsar.
  - Realistic fares and dynamic bidding counters.
- **Resilient Map Engine (`PartnerMap`):**
  - Renders interactive map canvas with GPS driver pulse, route waypoints, and pickup/drop markers.
  - Automatically switches to Google Maps once an API key is provided.

---

## 6. Google Maps Configuration

To enable native Google Maps:

### Android
Add your API key in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_ANDROID_MAPS_API_KEY"/>
  </application>
</manifest>
```

### iOS
Add your API key in `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 7. Firebase Integration Guide

The service and repository layers are designed with pluggable repository interfaces (`AuthRepository`, `JobRepository`, `EarningsRepository`, etc.).

### Enabling Firebase:
1. Generate `firebase_options.dart` using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```
2. In `lib/main.dart`, uncomment:
   ```dart
   // await Firebase.initializeApp(
   //   options: DefaultFirebaseOptions.currentPlatform,
   // );
   ```
3. Swap Riverpod repository providers in `lib/providers/` from `MockXRepository` to `FirebaseXRepository`.

### Firestore Collections Schema:
- `partners/`: Partner profiles, ratings, active status, bank account metadata.
- `vehicles/`: Fleet registry, registration numbers, verification certificates.
- `jobs/`: General dispatch job metadata.
- `rides/`: Live passenger trips and state machine progression.
- `porter_jobs/`: Intra-city cargo deliveries and item weights.
- `truck_loads/`: Inter-city freight board and load postings.
- `bids/`: Partner bids and shipper counter-offers.
- `earnings/`: Daily, weekly, monthly earnings aggregation and transactions.
- `documents/`: Uploaded KYC documents and verification statuses.
- `support_tickets/`: Partner help center inquiries.

---

## 8. Interactive Workflows

The application supports end-to-end interactive journeys:

1. **Driver Go-Online Flow:**
   - Tap the prominent `OnlineStatusToggle` on the home screen.
   - Status instantly switches to `● YOU ARE ONLINE` and populates nearby available jobs.
2. **Ride Flow:**
   - Simulated incoming job popup with countdown timer.
   - Accept Job ➔ Navigate to Pickup ➔ Arrived at Pickup ➔ Start Trip ➔ Arrive at Drop ➔ Trip Completed ➔ Fare Breakdown ➔ Customer Rating.
3. **Porter Logistics Flow:**
   - Accept Porter Request ➔ Going to Pickup ➔ Goods Loaded (verification) ➔ Delivery In Progress ➔ Goods Delivered ➔ Complete.
4. **Truck Load & Bidding Flow:**
   - Browse marketplace ➔ Inspect load specs (weight, material, deadline) ➔ Enter custom bid amount (e.g. ₹3,500) ➔ Receive simulated counter-offer (₹3,400) ➔ Accept, Counter, or Decline.
5. **Vehicle & Document Management:**
   - View fleet with verified status badges.
   - Multi-step wizard to register new vehicles and upload RC, Insurance, Permit, and Fitness certificates.

---

## 9. Testing & Quality Assurance

COOLI PARTNER has been verified with strict static analysis and automated unit/widget tests:

```bash
# Run static analyzer
flutter analyze

# Run unit tests covering Auth, Jobs, Bidding, Earnings, and Widgets
flutter test
```

### Test Coverage Highlights:
- **Authentication State:** Phone verification, OTP validation, registration step completion.
- **Job Workflows:** Online/Offline toggle, job acceptance, state machine progression.
- **Bidding Engine:** Custom bid submission, status transitions.
- **Earnings Computations:** Gross/Net calculation, period filtering (today, week, month).
- **Fleet Validation:** Vehicle addition validation and document status checks.
- **Widget Sanity:** App buttons, status badges, and scaffold rendering.

---

## 10. License

Copyright © 2026 COOLI Logistics Technologies. All rights reserved.
#   c o o l i _ p a r t n e r _ m o b i l e _ a p p  
 