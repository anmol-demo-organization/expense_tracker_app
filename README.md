# Expense Tracker

A Flutter expense tracking application with PostgreSQL database backend, designed for cross-platform use on macOS, Windows, and mobile platforms.

## Features

- ✅ Add, edit, and delete expenses
- ✅ Categorize expenses with colored categories
- ✅ Search and filter expenses
- ✅ Date range filtering
- ✅ Real-time expense totals
- ✅ Clean, modern Material Design 3 UI
- ✅ PostgreSQL database integration

## Prerequisites

Before running the app, make sure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH

2. **PostgreSQL** (12 or higher)
   - **macOS**: Install via Homebrew: `brew install postgresql`
   - **Windows**: Download installer from [postgresql.org](https://www.postgresql.org/download/windows/)
   - **Or**: Download from [postgresql.org](https://www.postgresql.org/download/) for all platforms

3. **Platform-specific requirements:**
   - **macOS**: Xcode (for iOS/macOS development) - Install from the Mac App Store
   - **Windows**: Visual Studio Community (for Windows desktop development) - Optional but recommended

## Database Setup

1. **Start PostgreSQL service:**
   ```bash
   brew services start postgresql
   ```

2. **Create the database and tables:**
   ```bash
   psql postgres
   ```
   
   Then run the SQL commands from `database_setup.sql`:
   ```sql
   \i database_setup.sql
   ```

3. **Update database configuration:**
   - Edit `lib/config/database_config.dart`
   - Update the PostgreSQL username and password to match your setup:
   ```dart
   static const String username = 'your_username';
   static const String password = 'your_password';
   ```

## Windows Setup Instructions

### Prerequisites for Windows

1. **Install Flutter on Windows:**
   - Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
   - Extract to a folder (e.g., `C:\flutter`)
   - Add Flutter to your system PATH:
     - Open **System Properties** > **Advanced** > **Environment Variables**
     - Add `C:\flutter\bin` to your PATH variable
   - Restart Command Prompt/PowerShell

2. **Install PostgreSQL on Windows:**
   - Download the Windows installer from [postgresql.org](https://www.postgresql.org/download/windows/)
   - Run the installer and follow the setup wizard
   - Remember the password you set for the `postgres` user
   - Default port is 5432 (recommended to keep it)
   - PostgreSQL will be installed as a Windows service and start automatically

### Database Setup on Windows

1. **Start PostgreSQL service (if not already running):**
   - Open **Services** (search for "Services" in Start menu)
   - Find "postgresql-x64-xx" service
   - Right-click and select **Start** if it's not running
   
   Or use Command Prompt as Administrator:
   ```cmd
   net start postgresql-x64-14
   ```

2. **Create the database using Command Prompt:**
   ```cmd
   cd /d "C:\Program Files\PostgreSQL\14\bin"
   psql -U postgres -d postgres
   ```
   Enter the password you set during installation.

3. **Run the database setup:**
   ```sql
   \i C:\path\to\your\expense_tracker\database_setup.sql
   ```
   
   Or copy-paste the SQL commands from `database_setup.sql` directly into the psql prompt.

### Running the App on Windows

1. **Open Command Prompt or PowerShell:**
   ```cmd
   cd C:\path\to\your\expense_tracker
   ```

2. **Install dependencies:**
   ```cmd
   flutter pub get
   ```

3. **Check Flutter setup:**
   ```cmd
   flutter doctor
   ```
   This will show you if there are any issues with your Flutter installation.

4. **Enable Windows desktop support:**
   ```cmd
   flutter config --enable-windows-desktop
   ```

5. **Run the app on Windows:**
   ```cmd
   flutter run -d windows
   ```

### Windows-Specific Configuration

1. **Update database configuration for Windows:**
   Edit `lib/config/database_config.dart` and ensure the connection parameters match your Windows PostgreSQL setup:
   ```dart
   static const String host = 'localhost';
   static const int port = 5432;
   static const String database = 'expense_tracker';
   static const String username = 'postgres'; // or your custom username
   static const String password = 'your_password_here';
   ```

2. **Firewall considerations:**
   - Windows Firewall might block PostgreSQL connections
   - If you encounter connection issues, temporarily disable Windows Firewall or add an exception for PostgreSQL

### Windows-Specific Troubleshooting

#### Flutter Issues on Windows
- **Path issues**: Make sure Flutter is properly added to your PATH
- **PowerShell execution policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` if you get execution policy errors
- **Missing Visual Studio**: Install Visual Studio Community with C++ development tools if prompted by `flutter doctor`

#### PostgreSQL Issues on Windows
- **Service not running**: Check Services app and start PostgreSQL service manually
- **Connection refused**: Verify PostgreSQL is listening on port 5432:
  ```cmd
  netstat -an | findstr 5432
  ```
- **Authentication failed**: Double-check username and password in the configuration
- **Path issues**: Use full paths when running psql commands

#### Performance Tips for Windows
- **Antivirus exclusions**: Add Flutter SDK folder and your project folder to antivirus exclusions
- **Windows Defender**: Consider excluding Flutter and Dart processes from real-time protection

## Installation & Running

1. **Clone or navigate to the project directory:**
   ```bash
   cd expense_tracker
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup:**
   ```bash
   flutter doctor
   ```

4. **Run the app:**
   
   For macOS:
   ```bash
   flutter run -d macos
   ```
   
   For Windows:
   ```cmd
   flutter run -d windows
   ```
   
   For iOS Simulator:
   ```bash
   flutter run -d ios
   ```
   
   For Android:
   ```bash
   flutter run -d android
   ```

## Project Structure

```
expense_tracker/
├── lib/
│   ├── config/
│   │   └── database_config.dart      # Database configuration
│   ├── models/
│   │   ├── expense.dart              # Expense data model
│   │   └── category.dart             # Category data model
│   ├── providers/
│   │   └── expense_provider.dart     # State management
│   ├── screens/
│   │   ├── home_screen.dart          # Main screen
│   │   └── add_expense_screen.dart   # Add/edit expense screen
│   ├── services/
│   │   └── database_service.dart     # PostgreSQL database operations
│   ├── widgets/
│   │   ├── expense_list.dart         # Expense list component
│   │   ├── filter_bar.dart           # Search and filter component
│   │   └── summary_card.dart         # Total expenses summary
│   └── main.dart                     # App entry point
├── database_setup.sql                # Database schema
└── pubspec.yaml                      # Dependencies
```

## Key Dependencies

- **postgres**: PostgreSQL database connectivity
- **provider**: State management
- **intl**: Internationalization and date formatting
- **material_design_icons_flutter**: Additional icons

## Database Schema

### Categories Table
- `id`: Primary key
- `name`: Category name
- `color`: Hex color code
- `icon`: Icon identifier
- `created_at`: Timestamp

### Expenses Table  
- `id`: Primary key
- `title`: Expense title
- `amount`: Expense amount (decimal)
- `description`: Optional description
- `category_id`: Foreign key to categories
- `expense_date`: Date of expense
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

## Default Categories

The app comes with 10 pre-configured categories:
- Food & Dining
- Transportation  
- Shopping
- Entertainment
- Bills & Utilities
- Healthcare
- Travel
- Education
- Personal Care
- Other

## Usage

1. **Adding Expenses:**
   - Tap the "+" floating action button
   - Fill in title, amount, category, and date
   - Optionally add a description
   - Tap "Add Expense"

2. **Filtering Expenses:**
   - Use the search bar to find specific expenses
   - Filter by category using the category chip
   - Filter by date range using the date chip

3. **Editing/Deleting:**
   - Tap on any expense to edit it
   - Use the three-dot menu for quick actions
   - Confirm deletion when prompted

## Troubleshooting

### Database Connection Issues
- **macOS**: Ensure PostgreSQL is running: `brew services start postgresql`
- **Windows**: Check PostgreSQL service in Services app or run `net start postgresql-x64-14`
- Check database credentials in `database_config.dart`
- **macOS**: Verify database exists: `psql -l`
- **Windows**: Verify database exists: `psql -U postgres -l`

### Flutter Issues
- Run `flutter doctor` to check setup
- Clear cache: `flutter clean && flutter pub get`
- Update Flutter: `flutter upgrade`

### Build Issues
- **macOS builds**: Ensure Xcode is updated for macOS builds
- **Windows builds**: Ensure Visual Studio Community with C++ tools is installed
- **iOS builds**: Check iOS deployment target for iOS builds
- **Android builds**: Verify Android SDK setup for Android builds

## Development Notes

- The app uses Provider for state management
- Database operations are asynchronous
- Material Design 3 theming is implemented
- The UI is responsive and follows Flutter best practices

## License

This project is open source and available under the MIT License.
