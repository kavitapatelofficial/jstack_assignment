# jWallet Lite — Digital Wallet Mobile Application

[![Flutter Version](https://img.shields.io/badge/Flutter-3.41.6-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.11.4-blue.svg)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20MVVM-green.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-purple.svg)]()
[![License](https://img.shields.io/badge/License-Confidential%20--%20jStack-red.svg)]()

> **Technical Assessment — Round 1 | Flutter Developer**  
> Candidate Submission for **jStack** | Position: Flutter Developer (2–5 years)

---

## 1. Project Overview

**jWallet Lite** is a lightweight, fintech digital wallet mobile application developed with **Flutter** and **Dart**, integrated with an independent **Mock REST API Backend** built with **Node.js & Express**.

The project implements a modern fintech user experience following Material Design 3 guidelines, strict Clean Architecture / MVVM separation of concerns, comprehensive automated test coverage, and backend-authoritative balance calculation with idempotency protection.

---

## 2. Architecture & Design Decisions

### Layered Architecture (Clean Architecture + MVVM)

The codebase strictly enforces the separation of concerns across three core architectural layers:

```
lib/
├── core/                        # Cross-cutting foundational modules
│   ├── constants/               # API endpoints, design tokens, AppColors
│   ├── network/                 # Dio client, typed ApiExceptions, interceptors
│   ├── storage/                 # SharedPreferences session & token persistence
│   ├── theme/                   # Material Design 3 light & dark themes
│   └── utils/                   # CurrencyFormatter, DateFormatter, Validators
├── data/                        # Concrete data implementations
│   ├── models/                  # API data models
│   ├── repositories/            # Repository implementations (caching, mapping)
│   └── services/                # Raw HTTP services (Auth, Wallet, Transactions)
├── domain/                      # Authoritative domain & business rules
│   ├── entities/                # Immutable entities (User, Wallet, Transaction, TransferResult)
│   └── repositories/            # Abstract repository contracts
├── presentation/                # UI Presentation Layer (MVVM)
│   ├── routing/                 # GoRouter declarative navigation with auth guards
│   ├── viewmodels/              # ChangeNotifier ViewModels (Auth, Wallet, Transfer, History, Theme)
│   ├── views/                   # 7 Core Screens (Login, Dashboard, Send Money, Confirmation, Result, History, Details)
│   └── widgets/                 # Reusable components (BalanceCard, TransactionTile, StatusBadge, ErrorView, EmptyView)
└── main.dart                    # Application entrypoint & dependency injection setup
```

### Key Architectural Decisions:
1. **MVVM with ChangeNotifier & Provider:** Provides predictable state updates, seamless UI rebuilds, testability, and decoupling of UI from business logic.
2. **Backend-Authoritative Balance:** The client application never modifies the balance locally. Deductions and validations are strictly performed by the backend server, and the resulting authoritative balance is propagated back to the presentation layer.
3. **Idempotency Support:** All money transfers send a unique `Idempotency-Key` header (`UUID v4`). The backend prevents duplicate charges on repeated or re-transmitted requests.
4. **Declarative Navigation (GoRouter):** Centralized route table with reactive authentication guards (`refreshListenable`) protecting private screens.
5. **Robust Error Handling:** Typed domain exceptions (`InsufficientFundsException`, `UnauthorizedException`, `ValidationException`, `NetworkConnectionException`) cleanly map HTTP response codes to user-friendly messages.
6. **Offline Caching:** Cached wallet balance and recent transactions in persistent local storage so users can immediately view their account status even in low-connectivity conditions.
7. **Bonus Features Implemented:**
   - Dark Mode & Light Mode toggle with persistence.
   - Transaction search by beneficiary name or transaction ID.
   - Transaction filter chips (All, Credits, Debits).
   - In-app configurable server host dialog (allows switching between Android Emulator, iOS Simulator, and physical device IPs without recompiling).

---

## 3. Technology Stack & Prerequisites

### Mobile Application
- **Flutter Framework:** `3.41.6` (Channel stable)
- **Dart SDK:** `3.11.4`
- **State Management:** `provider: ^6.1.5+1`
- **Navigation:** `go_router: ^17.5.0`
- **HTTP Client:** `dio: ^5.11.1`
- **Storage:** `shared_preferences: ^2.5.6`
- **Formatting:** `intl: ^0.20.3`
- **UUID:** `uuid: ^4.6.0`
- **Testing:** `flutter_test`, `mocktail: ^1.0.5`

### Mock REST API Backend
- **Runtime:** Node.js `v18+` or `v20+` (tested with Node `v23.11.0` and npm `10.9.2`)
- **Framework:** Express.js `4.21.2`
- **Middleware:** `cors: ^2.8.5`

---

## 4. Quick Start & Setup Guide

### Step 1: Clone the Repository
```bash
git clone <repository-url>
cd jstack_assignment
```

### Step 2: Run the Mock REST API Backend
In a separate terminal window:
```bash
cd mock-backend
npm install
npm start
```
The mock server will start on `http://localhost:3000` (or `0.0.0.0:3000`).

To verify backend health:
```bash
curl http://localhost:3000/health
# Response: {"status":"ok","service":"jWallet Lite Mock API"}
```

### Step 3: Run the Flutter Mobile Application
In the project root directory:
```bash
flutter pub get
flutter run
```

---

## 5. API Base URL & Device Connectivity

The application automatically resolves the appropriate backend base URL based on the running platform:

| Environment | Default Base URL | Note |
|---|---|---|
| **Android Emulator** | `http://10.0.2.2:3000` | Loopback alias to host machine localhost |
| **iOS Simulator** | `http://localhost:3000` | Native host network loopback |
| **macOS / Web** | `http://localhost:3000` | Direct local connection |
| **Physical Android / iOS Device** | `http://<YOUR_COMPUTER_LOCAL_IP>:3000` | Device & computer must be on the same Wi-Fi |

> **Tip:** You can also configure the Base URL directly inside the app on the Login Screen by tapping the **Settings Icon** in the top right corner.

---

## 6. Demo Credentials & Testing Workflow

### Credentials
- **Email:** `demo@jstack.co`
- **Password:** `Demo@123`

*(A quick **"Fill Form"** button is also provided on the Login screen for faster evaluator testing)*

### Recommended Walkthrough:
1. **Login:** Enter demo credentials or tap "Fill Form", then tap **Sign In**.
2. **Dashboard:**
   - View initial balance: `₹25,450.75`.
   - Toggle eye icon to mask/unmask balance.
   - Pull down to trigger pull-to-refresh.
   - Tap Theme icon in the AppBar to switch between Dark & Light mode.
3. **Send Money:**
   - Tap **Send Money** quick action.
   - Tap frequent contact chip (e.g. `Rahul Sharma`).
   - Enter transfer amount (e.g., `1500.00`).
   - Tap **Review & Transfer**.
   - Review transfer confirmation sheet and tap **Confirm & Pay**.
4. **Success Screen:**
   - Verify transaction reference, date, amount, and updated balance (`₹23,950.75`).
   - Tap **Back to Dashboard** to see recent transactions updated immediately.
5. **Validation & Error Scenarios:**
   - Try logging in with wrong password (`wrong@123`) $\rightarrow$ see HTTP 401 error message.
   - Try sending an amount greater than balance (e.g. `99,999.00`) $\rightarrow$ see client and backend HTTP 409 `Insufficient wallet balance` rejection.
   - Try sending with invalid 5-digit phone number $\rightarrow$ see phone number validation error.
6. **Transaction History & Details:**
   - Tap **See All** or **History** to view transactions list.
   - Use search bar to search `Swiggy` or `Rahul`.
   - Filter by `Credits` or `Debits`.
   - Tap any transaction tile to open full **Transaction Details**.

---

## 7. Automated Testing

The project includes unit and widget test suites covering all required scenarios:
- **Login form validation:** Email regex, required checks, password length.
- **Transfer amount validation:** Numeric validation, zero/negative rejection, balance limit checks.
- **Insufficient balance handling:** Error handling with mocked repository and custom exception mapping.
- **Successful transfer state update:** Verifies authoritative balance propagation.
- **Duplicate submission prevention & idempotency:** Guard tests preventing multiple simultaneous API calls.
- **Widget tests:** Balance card toggle, transaction tile rendering, status badge styling.

### Run All Tests:
```bash
flutter test
```

### Run Static Analysis:
```bash
flutter analyze
```

---

## 8. Backend Endpoints Summary

| Method | Endpoint | Description | Status Codes |
|---|---|---|---|
| `POST` | `/api/v1/auth/login` | Authenticate user | `200`, `400`, `401` |
| `GET` | `/api/v1/users/profile` | Fetch user profile | `200`, `401` |
| `GET` | `/api/v1/wallet/balance` | Fetch authoritative wallet balance | `200`, `401` |
| `GET` | `/api/v1/transactions` | Fetch transactions (supports `?type=` & `?search=`) | `200`, `401` |
| `POST` | `/api/v1/transactions/transfer` | Transfer money (with idempotency support) | `200`, `400`, `401`, `409` |
| `GET` | `/api/v1/transactions/:id` | Fetch single transaction details | `200`, `401`, `404` |
| `POST` | `/api/v1/wallet/reset` | Reset mock database to initial state | `200` |

### API Documentation:
- **OpenAPI 3.0 Specification:** `api-docs/openapi.json`
- **Postman Collection:** `api-docs/jwallet_postman_collection.json`

---

## 9. Deliverables & Submission Checklist

- [x] **A. Source Code:** Clean Flutter project repository with Node.js mock backend.
- [x] **B. Application Build:** Android APK (`build/app/outputs/flutter-apk/app-debug.apk`).
- [x] **C. API Documentation:** Postman collection and OpenAPI 3.0 specification in `api-docs/`.
- [x] **D. Screenshots:** Major screen captures in `docs/screenshots/`.
- [x] **E. Demonstration Video:** Video recording showing all key flows.
- [x] **F. README:** Detailed architecture, setup, and test instructions.

---

## 10. Known Limitations & Disclosure

- **Mock API Backend:** Runs in-memory with seed transactions for simplicity and zero database setup. For production, persistent database (PostgreSQL/MongoDB) with real JWT signing and refresh tokens would be utilized.
- **AI-Assisted Development Disclosure:** Developed with assistance from Gemini/Antigravity code intelligence tools for scaffolding, architectural validation, and test authoring. All architecture, design decisions, and implementations have been thoroughly reviewed, verified, and tested.
