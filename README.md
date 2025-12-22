# BillSnap - Serverless Receipt Splitter

A Flutter application that allows users to scan receipts using on-device OCR (ML Kit), extract items, and interactively split bills with friends using weighted splits in real-time.

## Features

- 📷 **Receipt Scanning**: Use ML Kit's on-device OCR to extract items from receipts
- 🔥 **Real-time Sync**: Firestore streams for live bill state synchronization
- ⚖️ **Weighted Splits**: Support for quantity-based splits (e.g., 3 people sharing 6 items)
- 👥 **Multi-participant**: Add friends to bills and track individual totals
- 🔐 **Firebase Auth**: Secure email/password authentication

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: flutter_bloc (Cubit pattern)
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **OCR**: Google ML Kit Text Recognition (on-device)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── app_user.dart        # User model
│   ├── bill.dart            # Bill model
│   ├── bill_item.dart       # BillItem with weighted split logic
│   └── models.dart          # Export file
├── services/                 # Business logic services
│   ├── auth_service.dart    # Firebase Auth wrapper
│   ├── firestore_service.dart # Firestore operations
│   ├── receipt_scanner_service.dart # ML Kit OCR
│   └── services.dart        # Export file
├── cubit/                    # State management
│   ├── auth/                # Authentication state
│   ├── bill/                # Bill operations state
│   ├── scanner/             # Scanner state
│   └── cubit.dart           # Export file
└── ui/                       # User interface
    ├── theme/               # App theming
    ├── screens/             # App screens
    └── widgets/             # Reusable widgets
```

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project called "BillSnap"
3. Enable Authentication with Email/Password provider
4. Create a Firestore database

### 2. Android Setup

1. Add an Android app in Firebase Console
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`

### 3. iOS Setup

1. Add an iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Firestore Rules

Deploy these security rules to Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bills collection
    match /bills/{billId} {
      // Allow list queries where user is in participants array
      allow list: if request.auth != null;
      // Allow single document read if user is a participant
      allow get: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow delete: if request.auth != null && 
        request.auth.uid == resource.data.hostId;
    }
  }
}
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.9.0)
- Android Studio / Xcode
- Firebase project configured

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase (see Firebase Setup above)

4. Run the app:
   ```bash
   flutter run
   ```

## Key Features Implementation

### Weighted Split Logic

The `BillItem` class implements weighted splitting:

```dart
double getPriceForUser(String uid) {
  final userShares = shares[uid] ?? 0;
  if (totalShares == 0 || userShares == 0) return 0;
  return (price / totalShares) * userShares;
}
```

**Example**: Item costs $12, split as:
- User A: 3 shares → $6.00
- User B: 2 shares → $4.00
- User C: 1 share → $2.00

### Data Model

```
bills/
  {billId}/
    hostId: "userUid"
    status: "active" | "closed"
    participants: ["uid1", "uid2", ...]
    items: [
      {
        id: "uuid",
        name: "Burger",
        price: 12.99,
        shares: {
          "uid1": 2,  // User 1 takes 2 portions
          "uid2": 1   // User 2 takes 1 portion
        }
      }
    ]
    createdAt: Timestamp
```

## License

This project is for educational purposes.

