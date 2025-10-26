import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense; // For editing existing expenses

  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    final expense = widget.expense!;
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description ?? '';
    _selectedDate = expense.expenseDate;
    
    // Find the category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExpenseProvider>();
      _selectedCategory = provider.getCategoryById(expense.categoryId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteExpense,
            ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter expense title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: provider.categories.map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                  category.color.replaceFirst('#', '0xff'))),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add a description',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: _saveExpense,
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Update Expense' : 'Add Expense'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  if (provider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ExpenseProvider>();
    final expense = Expense(
      id: isEditing ? widget.expense!.id : null,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id,
      expenseDate: _selectedDate,
    );

    if (isEditing) {
      await provider.updateExpense(expense);
    } else {
      await provider.addExpense(expense);
    }

    if (provider.error == null) {
      Navigator.of(context).pop();
    }
  }

  void _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<ExpenseProvider>();
      await provider.deleteExpense(widget.expense!.id!);
      if (provider.error == null) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
