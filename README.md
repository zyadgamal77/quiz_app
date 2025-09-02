# Smart Quiz App

A Flutter-based quiz application that allows users to test their knowledge across various categories. The app features a clean, user-friendly interface with role-based access control for both learners and administrators.

## Features

- **User Authentication**: Secure login and signup with email/password
- **Role-Based Access**: Separate interfaces for learners and administrators
- **Category Browsing**: Browse quizzes by different categories
- **Search Functionality**: Easily find specific quiz categories
- **Responsive Design**: Works on multiple screen sizes and orientations
- **Modern UI**: Clean and intuitive user interface with smooth animations

## Screenshots

*(Screenshots will be added here)*

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Firebase account (for authentication and database)
- Android Studio / Xcode (for building the app)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/quiz_app.git
   cd quiz_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download and add the configuration files:
     - Android: `google-services.json` to `android/app/`
     - iOS: `GoogleService-Info.plist` to `ios/Runner/`

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                # Application entry point
├── model/                  # Data models
│   └── category.dart       # Category model
│   └── question.dart       # Question model
│   └── quiz.dart           # Quiz model
├── services/               # Business logic
│   └── auth_service.dart   # Authentication service
├── theme/                  # App theming
│   └── theme.dart          # Theme configuration
├── utils/                  # Utility classes
│   └── auth_utils.dart     # Authentication utilities
└── view/                   # UI components
    ├── auth/               # Authentication screens
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── user/               # User-facing screens
    │   ├── home_screen.dart
    │   └── category_screen.dart
    └── admin/              # Admin screens
        └── admin_home_screen.dart
```

## Dependencies

- `firebase_core`: ^2.15.1
- `firebase_auth`: ^4.9.0
- `cloud_firestore`: ^4.9.1
- `provider`: ^6.0.5
- `flutter_animate`: ^4.2.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- All open-source contributors whose packages are used in this project
