# Popp - Bikerverse

Popp is a Flutter-based mobile application designed for the biker community. It provides a platform
for bikers to connect, share their experiences, and discover new routes and events.

## Features

- **User Authentication:** Secure sign-up and login with email/password, Google Sign-In, and Sign in
  with Apple.
- **Social Feed:** A timeline to share and view posts, images, and updates from other bikers.
- **Image and File Sharing:** Users can share images and files with the community.
- **Real-time Notifications:** Stay updated with real-time push notifications using Firebase Cloud
  Messaging.
- **In-App Purchases:** Unlock premium features through in-app purchases.
- **Profile Management:** Users can create and manage their profiles.
- **App-wide Theming:** Consistent dark theme across the application.
- **Dynamic Content:** Remote configuration for fetching dynamic content and feature flagging.

## Dependencies

This project uses शरीर of open-source packages, including:

- **State Management:** [provider](https://pub.dev/packages/provider)
- **UI:**
    - [smooth_page_indicator](https://pub.dev/packages/smooth_page_indicator)
    - [carousel_slider](https://pub.dev/packages/carousel_slider)
    - [shimmer](https://pub.dev/packages/shimmer)
    - [lottie](https://pub.dev/packages/lottie)
    - [flutter_spinkit](https://pub.dev/packages/flutter_spinkit)
- **Firebase:**
    - [firebase_core](https://pub.dev/packages/firebase_core)
    - [cloud_firestore](https://pub.dev/packages/cloud_firestore)
    - [firebase_storage](https://pub.dev/packages/firebase_storage)
    - [firebase_auth](https://pub.dev/packages/firebase_auth)
    - [firebase_messaging](https://pub.dev/packages/firebase_messaging)
    - [firebase_app_check](https://pub.dev/packages/firebase_app_check)
    - [firebase_remote_config](https://pub.dev/packages/firebase_remote_config)
- **Authentication:**
    - [google_sign_in](https://pub.dev/packages/google_sign_in)
    - [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)
- **Local Storage:**
    - [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Utilities:**
    - [http](https://pub.dev/packages/http)
    - [url_launcher](https://pub.dev/packages/url_launcher)
    - [image_picker](https://pub.dev/packages/image_picker)
    - [file_picker](https://pub.dev/packages/file_picker)
    - [uuid](https://pub.dev/packages/uuid)
    - [logger](https://pub.dev/packages/logger)
    - [intl](https://pub.dev/packages/intl)
    - [share_plus](https://pub.dev/packages/share_plus)
    - [package_info_plus](https://pub.dev/packages/package_info_plus)

## Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/ganganaidu/popp.git
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the app:**
   ```sh
   flutter run
   ```

## Contributing

Contributions are welcome! Please feel free to submit a pull request.

