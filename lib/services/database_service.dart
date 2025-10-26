import 'package:postgres/postgres.dart';
import '../config/database_config.dart';
import '../models/expense.dart';
import '../models/category.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Connection? _connection;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Connection> get connection async {
    if (_connection == null || _connection!.isOpen == false) {
      _connection = await Connection.open(
        Endpoint(
          host: DatabaseConfig.host,
          port: DatabaseConfig.port,
          database: DatabaseConfig.database,
          username: DatabaseConfig.username,
          password: DatabaseConfig.password,
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
    }
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // Category operations
  Future<List<Category>> getCategories() async {
    final conn = await connection;
    final result = await conn.execute(
      'SELECT id, name, color, icon, created_at FROM categories ORDER BY name'
    );
    
    return result.map((row) => Category.fromMap({
      'id': row[0],
      'name': row[1],
      'color': row[2],
      'icon': row[3],
      'created_at': row[4].toString(),
    })).toList();
  }

  Future<Category> createCategory(Category category) async {
    final conn = await connection;
    final result = await conn.execute(
      '''
      INSERT INTO categories (name, color, icon) 
      VALUES (\$1, \$2, \$3) 
      RETURNING id, name, color, icon, created_at
      ''',
      parameters: [category.name, category.color, category.icon],
    );

    final row = result.first;
    return Category.fromMap({
      'id': row[0],
      'name': row[1],
      'color': row[2],
      'icon': row[3],
      'created_at': row[4].toString(),
    });
  }

  // Expense operations
  Future<List<Expense>> getExpenses({
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    final conn = await connection;
    
    String query = '''
      SELECT id, title, amount, description, category_id, expense_date, created_at, updated_at 
      FROM expenses 
      WHERE 1=1
    ''';
    
    List<Object?> parameters = [];
    int paramIndex = 1;

    if (categoryId != null) {
      query += ' AND category_id = \$${paramIndex++}';
      parameters.add(categoryId);
    }

    if (startDate != null) {
      query += ' AND expense_date >= \$${paramIndex++}';
      parameters.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query += ' AND expense_date <= \$${paramIndex++}';
      parameters.add(endDate.toIso8601String().split('T')[0]);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (title ILIKE \$${paramIndex++} OR description ILIKE \$${paramIndex++})';
      parameters.addAll(['%$searchQuery%', '%$searchQuery%']);
      paramIndex++; // Account for the second parameter
    }

    query += ' ORDER BY expense_date DESC, created_at DESC LIMIT \$${paramIndex++} OFFSET \$${paramIndex++}';
    parameters.addAll([limit, offset]);

    final result = await conn.execute(query, parameters: parameters);
    
    return result.map((row) => Expense.fromMap({
      'id': row[0],
      'title': row[1],
      'amount': row[2],
      'description': row[3],
      'category_id': row[4],
      'expense_date': row[5].toString(),
      'created_at': row[6].toString(),
      'updated_at': row[7].toString(),
    })).toList();
  }

  Future<Expense> createExpense(Expense expense) async {
    final conn = await connection;
    final result = await conn.execute(
      '''
      INSERT INTO expenses (title, amount, description, category_id, expense_date) 
      VALUES (\$1, \$2, \$3, \$4, \$5) 
      RETURNING id, title, amount, description, category_id, expense_date, created_at, updated_at
      ''',
      parameters: [
        expense.title,
        expense.amount,
        expense.description,
        expense.categoryId,
        expense.expenseDate.toIso8601String().split('T')[0],
      ],
    );

    final row = result.first;
    return Expense.fromMap({
      'id': row[0],
      'title': row[1],
      'amount': row[2],
      'description': row[3],
      'category_id': row[4],
      'expense_date': row[5].toString(),
      'created_at': row[6].toString(),
      'updated_at': row[7].toString(),
    });
  }

  Future<Expense> updateExpense(Expense expense) async {
    final conn = await connection;
    final result = await conn.execute(
      '''
      UPDATE expenses 
      SET title = \$2, amount = \$3, description = \$4, category_id = \$5, expense_date = \$6
      WHERE id = \$1
      RETURNING id, title, amount, description, category_id, expense_date, created_at, updated_at
      ''',
      parameters: [
        expense.id,
        expense.title,
        expense.amount,
        expense.description,
        expense.categoryId,
        expense.expenseDate.toIso8601String().split('T')[0],
      ],
    );

    final row = result.first;
    return Expense.fromMap({
      'id': row[0],
      'title': row[1],
      'amount': row[2],
      'description': row[3],
      'category_id': row[4],
      'expense_date': row[5].toString(),
      'created_at': row[6].toString(),
      'updated_at': row[7].toString(),
    });
  }

  Future<void> deleteExpense(int id) async {
    final conn = await connection;
    await conn.execute('DELETE FROM expenses WHERE id = \$1', parameters: [id]);
  }

  Future<double> getTotalExpenses({
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conn = await connection;
    
    String query = 'SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE 1=1';
    List<Object?> parameters = [];
    int paramIndex = 1;

    if (categoryId != null) {
      query += ' AND category_id = \$${paramIndex++}';
      parameters.add(categoryId);
    }

    if (startDate != null) {
      query += ' AND expense_date >= \$${paramIndex++}';
      parameters.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query += ' AND expense_date <= \$${paramIndex++}';
      parameters.add(endDate.toIso8601String().split('T')[0]);
    }

    final result = await conn.execute(query, parameters: parameters);
    return (result.first[0] as num).toDouble();
  }
}
