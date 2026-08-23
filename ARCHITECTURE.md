# Popp — Application Architecture ("new arch")

This document is the **canonical template** for the architecture migration. Every
feature is expected to converge on the structure and conventions below. The
`products` feature is the reference implementation — copy its shape.

## 1. Feature-first layout

Every data-backed feature lives under `lib/src/<feature>/` with up to four layers:

```
lib/src/<feature>/
  model/        # Feature-specific data classes (optional; shared models stay in lib/src/models)
  repository/   # Data access ONLY. Firestore/Storage/HTTP. No BuildContext, no widgets.
  viewmodel/    # ChangeNotifier. Holds UI state, orchestrates repositories. No Firestore calls.
  ui/           # Screens & widgets. Render state, dispatch intent to the viewmodel.
```

Purely static screens with no data or logic (e.g. `about_us`, `disclaimers`,
`intro`) stay as plain widgets — they do **not** need the 4-layer structure.

### Layer rules

- **repository** — the only place that touches `FirebaseFirestore`, `FirebaseStorage`,
  `FirebaseAuth`, etc. Returns plain data (`Map<String, dynamic>`, typed models, or
  streams). Never imports `flutter/material.dart` for UI, never takes a `BuildContext`.
- **viewmodel** — extends `ChangeNotifier`. Takes its repository via the constructor
  (constructor injection). Exposes immutable-ish state fields + `notifyListeners()`.
  Contains no `Firestore` references and no widget building. Owns `dispose()` for
  stream subscriptions.
- **ui** — `StatelessWidget`/`StatefulWidget` that reads the viewmodel through
  `Provider` (`context.watch` / `context.read` / `Consumer`). No business logic and
  no direct Firestore access in widgets.

## 2. State management — Provider + ChangeNotifier

- **App-scoped** viewmodels/services (needed app-wide, no per-screen args) are
  registered once in `lib/src/app_providers.dart`.
- **Screen-scoped** viewmodels (that need route arguments — e.g. a product detail VM
  seeded with a specific product) are provided **at the route** via a
  `ChangeNotifierProvider` in the `GoRoute` builder, so their lifecycle matches the
  screen. See `app_router.dart` → `/product-detail`.

## 3. Navigation — go_router (declarative)

- The single source of truth is `lib/src/navigation/app_router.dart` (`GoRouter router`).
- Route **paths** and **typed navigation helpers** live in
  `lib/src/navigation/app_routes.dart`:
  - `AppRoutes` — path string constants.
  - `AppNavigation` — a `BuildContext` extension with typed `push*` methods, e.g.
    `context.pushProductDetail(product)`. Call sites use these instead of building
    `MaterialPageRoute`s by hand.
- **Do not** use `Navigator.push(MaterialPageRoute(...))` or the legacy
  `nav_router.dart` helpers in migrated code. Those are being retired.
- Arguments are passed via `state.extra` using a small typed args class defined next
  to the screen (e.g. `ProductDetailArgs`). IDs for deep links use path params.
- The bottom-nav shell uses a `StatefulShellRoute` (replaces the old `nav_helper.dart`
  nested navigators).

## 4. Conventions

- Logging: `AppLogger` only (see `CODING_GUIDELINES.md`), never `print`.
- Firestore collection names: `ApiUrl.*`, never hardcoded strings.
- After every change: `flutter analyze` must stay clean (no new errors/warnings).

## 5. Migration status

| Feature        | repository | viewmodel | ui/ | go_router | Notes                    |
|----------------|:----------:|:---------:|:---:|:---------:|--------------------------|
| products       | ✅ | ✅ | ✅ | ✅ | Reference implementation |
| adbanner       | ✅ | ✅ | ✅ | — | Pre-existing             |
| dashboard      | ✅ | ✅ | —  | — | Screens still at root    |
| services       | ✅ | partial | — | ✅ | Nav fully on go_router; `service_listing` on MVVM. `service_detail` + the big forms now go through `ServiceRepository`/`ProductRepository` (repository seam) instead of the shared API. Screens kept in existing sub-folders (listservices/bikes/accessories) as the ui layer. |
| home / shell   | n/a | n/a | ✅ | ✅ | `HomeShell` on `StatefulShellRoute.indexedStack` (4 branches: /home, /explore, /chat, /more). `nav_helper.dart` + legacy `home_screen.dart` + `auth_wrapper.dart` deleted. |
| settings       | ✅ | — | — | ✅ | `ListingsRepository` (favorites/my-listings) + `UserProfileRepository` (profile read/write); auth via `AuthRepository`. |
| admin          | ✅ | — | — | ✅ | `AdminRepository` (pending queries) + `AdminNotificationService` (moderation). |
| search         | ✅ | — | — | ✅ | `SearchRepository` shared by search + explore. |
| chat           | service | provider* | — | ✅ | `ChatService` + `ActiveChatProvider` are the data + state layers |
| notifications  | service | — | — | ✅ | `NotificationService` is the repository |
| subscription   | service | ✅ | — | ✅ | `SubscriptionService` + `SubscriptionProvider` (ChangeNotifier) |
| login / auth   | ✅ | — | — | ✅ | `AuthRepository` wraps all sign-in/up/verify/reset/sign-out; screens no longer touch `FirebaseAuth` for operations. |

**Navigation: fully migrated.** `nav_router.dart` and `nav_helper.dart` are **deleted**. All navigation goes through go_router — declarative routes in `app_router.dart`, typed helpers in `app_routes.dart`. All legacy `Navigator.pushNamed`/`pushReplacementNamed` calls were converted to `context.go*`/`push*` (the only remaining `Navigator.pushNamed` lives in `splash_screen.dart`, which is unreferenced dead code).

Remaining MVVM work is repository/viewmodel extraction for features whose screens still hold inline Firestore (settings list screens, login auth). Several features (chat, subscription, notifications, admin) already satisfy the architecture through existing `*_service.dart` (repository role) + `*_provider.dart` (viewmodel role) — reorganizing those into `repository/`/`viewmodel/` subfolders is cosmetic and deferred.

Update this table as features are migrated.
