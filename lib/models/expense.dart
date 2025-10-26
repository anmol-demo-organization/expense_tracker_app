class Expense {
  final int? id;
  final String title;
  final double amount;
  final String? description;
  final int? categoryId;
  final DateTime expenseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    this.description,
    this.categoryId,
    required this.expenseDate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'expense_date': expenseDate.toIso8601String().split('T')[0], // Date only
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'],
      categoryId: map['category_id']?.toInt(),
      expenseDate: map['expense_date'] != null 
          ? DateTime.parse(map['expense_date'])
          : DateTime.now(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? expenseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
