# MyKhaata - Personal Finance Manager

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</div>

## 📱 About

MyKhaata is a comprehensive personal finance management application built with Flutter. It helps you track your income, expenses, manage budgets, and gain insights into your spending habits - all while keeping your data completely private and secure on your device.

### ✨ Key Features

- **📊 Transaction Management**
  - Track income and expenses with detailed categorization
  - Add notes, dates, and times to transactions
  - Support for multiple accounts (Cash, Bank, Mobile Wallets, etc.)
  - Search and filter transactions easily

- **💰 Budget Tracking**
  - Set monthly budget limits for each category
  - Visual progress indicators
  - Over-budget warnings and notifications
  - Compare budgets across months

- **📈 Analytics & Insights**
  - Interactive pie charts and bar graphs
  - Category-wise expense breakdown
  - Account-wise analysis
  - Monthly comparison views

- **🏦 Account Management**
  - Create unlimited accounts
  - Automatic balance tracking
  - View detailed transaction history per account
  - Custom icons and colors

- **🎨 Customization**
  - 5 beautiful color themes
  - Multiple currency symbols
  - Customizable categories and accounts
  - Flexible icon and color selection

- **🔒 Security & Privacy**
  - All data stored locally on device
  - Optional 4-digit passcode protection
  - No internet connection required
  - No data collection or sharing

- **💾 Data Management**
  - Backup and restore functionality
  - Export transactions to CSV
  - Delete/reset options
  - Import/restore from backup files

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 21+)

### Installation

1. Clone the repository
```bash
git clone https://github.com/Haadi-Balouch/MyKhaata-FlutterApp.git
cd MyKhaata-FlutterApp
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 🏗️ Architecture

MyKhaata follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── dao/              # Data Access Objects
├── db/               # Database configuration
├── models/           # Data models
├── screens/          # UI screens
├── utils/            # Utilities and helpers
└── widgets/          # Reusable widgets
```

### Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Charts**: fl_chart
- **Local Storage**: shared_preferences
- **File Operations**: file_picker, path_provider
- **Permissions**: permission_handler

## 📚 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  permission_handler: ^11.1.0
  url_launcher: ^6.2.2
  fl_chart: ^0.65.0
```

## 💡 Usage

### Adding a Transaction

1. Tap the **+** button at the bottom
2. Select **Income** or **Expense**
3. Choose an account and category
4. Enter the amount and optional note
5. Adjust date/time if needed
6. Tap **Save**

### Setting a Budget

1. Navigate to the **Budget** tab
2. Select the desired month
3. Tap **SET BUDGET** next to a category
4. Enter your budget limit
5. Tap **Save**

### Creating Backups

1. Open the drawer menu
2. Go to **Management** → **Backup & Restore**
3. Tap **BACKUP NOW**
4. Choose a directory to save the backup

### Exporting Data

1. Open the drawer menu
2. Go to **Management** → **Export**
3. Select date range
4. Tap **EXPORT NOW**
5. Data will be exported as CSV

## 🎨 Themes

MyKhaata includes 5 beautifully crafted themes:

1. **Classic Olive** - Traditional and professional
2. **Ocean Blue** - Calm and refreshing
3. **Forest Green** - Natural and balanced
4. **Royal Purple** - Bold and elegant
5. **Sunset Orange** - Warm and energetic

## 🔐 Security

- **Local Storage**: All data is stored locally using SQLite
- **Passcode Protection**: Optional 4-digit passcode
- **No Cloud Sync**: Your data never leaves your device
- **Privacy First**: No analytics, no tracking, no ads

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Haadi Baloch**
- Email: haadi.baloch.7880@gmail.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source contributors whose packages made this project possible
- Icons from Material Design

## 🐛 Bug Reports

If you encounter any issues, please [create an issue](https://github.com/Haadi_Balouch/MyKhaata-FlutterApp/issues) on GitHub.

## 📬 Contact & Feedback

Have questions or suggestions? Feel free to reach out!

- Email: haadi.baloch.7880@gmail.com
- Use the in-app feedback feature

---

<div align="center">
  Made with ❤️ using Flutter
</div>
