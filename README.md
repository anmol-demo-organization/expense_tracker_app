# Expense Tracker

A Flutter expense tracking application with PostgreSQL database backend, designed for macOS 12.7.4.

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
   - Install via Homebrew: `brew install postgresql`
   - Or download from [postgresql.org](https://www.postgresql.org/download/)

3. **Xcode** (for iOS/macOS development)
   - Install from the Mac App Store

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
- Ensure PostgreSQL is running: `brew services start postgresql`
- Check database credentials in `database_config.dart`
- Verify database exists: `psql -l`

### Flutter Issues
- Run `flutter doctor` to check setup
- Clear cache: `flutter clean && flutter pub get`
- Update Flutter: `flutter upgrade`

### Build Issues
- Ensure Xcode is updated for macOS builds
- Check iOS deployment target for iOS builds
- Verify Android SDK setup for Android builds

## Development Notes

- The app uses Provider for state management
- Database operations are asynchronous
- Material Design 3 theming is implemented
- The UI is responsive and follows Flutter best practices

## License

This project is open source and available under the MIT License.
