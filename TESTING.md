# Testing Guide

## Database Connection Test

To verify that your PostgreSQL database is set up correctly, you can run these tests:

### 1. Test PostgreSQL Connection

```bash
# Test PostgreSQL is running
psql -c "SELECT version();" postgres

# Test expense_tracker database exists
psql -c "\l" postgres | grep expense_tracker

# Test tables exist
psql expense_tracker -c "\dt"

# Test default categories were inserted
psql expense_tracker -c "SELECT name FROM categories;"
```

Expected output should show 10 categories:
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

### 2. Manual Database Test

You can manually test the database by inserting a test expense:

```sql
-- Connect to database
psql expense_tracker

-- Insert test expense
INSERT INTO expenses (title, amount, description, category_id, expense_date) 
VALUES ('Test Coffee', 4.50, 'Morning coffee at cafe', 1, CURRENT_DATE);

-- Verify insertion
SELECT e.title, e.amount, c.name as category, e.expense_date 
FROM expenses e 
JOIN categories c ON e.category_id = c.id;

-- Clean up test data
DELETE FROM expenses WHERE title = 'Test Coffee';
```

### 3. Flutter App Testing

1. **Install and run the app:**
   ```bash
   cd expense_tracker
   flutter pub get
   flutter run -d macos
   ```

2. **Test basic functionality:**
   - ✅ App starts without crashes
   - ✅ Categories load from database
   - ✅ Can add new expense
   - ✅ Expenses appear in list
   - ✅ Can edit existing expense
   - ✅ Can delete expense
   - ✅ Search function works
   - ✅ Category filter works
   - ✅ Date filter works

### 4. Common Issues and Solutions

**Issue:** "Connection refused" error
**Solution:** Start PostgreSQL service: `brew services start postgresql`

**Issue:** "Database does not exist" error
**Solution:** Run the database setup SQL commands

**Issue:** "Authentication failed" error
**Solution:** Update username/password in `lib/config/database_config.dart`

**Issue:** Flutter packages not found
**Solution:** Run `flutter pub get` in the project directory

**Issue:** App doesn't start on macOS
**Solution:** Ensure Xcode is installed and run `flutter doctor`
