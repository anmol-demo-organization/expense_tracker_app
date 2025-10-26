import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  int? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Getters
  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Initialize data
  Future<void> initialize() async {
    await loadCategories();
    await loadExpenses();
  }

  // Category operations
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _databaseService.getCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      _error = null;
      final newCategory = await _databaseService.createCategory(category);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  // Expense operations
  Future<void> loadExpenses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _databaseService.getExpenses(
        categoryId: _selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } catch (e) {
      _error = 'Failed to load expenses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _error = null;
      final newExpense = await _databaseService.createExpense(expense);
      _expenses.insert(0, newExpense);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      _error = null;
      final updatedExpense = await _databaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      _error = null;
      await _databaseService.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
    }
  }

  // Filter operations
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadExpenses();
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    loadExpenses();
  }

  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    loadExpenses();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    loadExpenses();
  }

  Category? getCategoryById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
