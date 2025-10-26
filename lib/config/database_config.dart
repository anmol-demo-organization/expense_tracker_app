class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'expense_tracker';
  static const String username = 'postgres';
  static const String password = 'password'; // Change this to your PostgreSQL password
  
  static String get connectionString => 
      'postgresql://$username:$password@$host:$port/$database';
}
