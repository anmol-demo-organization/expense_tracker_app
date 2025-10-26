import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../screens/add_expense_screen.dart';

class ExpenseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.loadExpenses(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ExpenseCard(
                expense: expense,
                onTap: () => _editExpense(context, expense),
                onDelete: () => _deleteExpense(context, expense),
              );
            },
          ),
        );
      },
    );
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
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
      context.read<ExpenseProvider>().deleteExpense(expense.id!);
    }
  }
}

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final category = provider.getCategoryById(expense.categoryId);
        final categoryColor = category != null
            ? Color(int.parse(category.color.replaceFirst('#', '0xff')))
            : Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Category indicator
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Main content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and amount row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  expense.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                NumberFormat.currency(symbol: '\$').format(expense.amount),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Category and date row
                          Row(
                            children: [
                              if (category != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: categoryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                DateFormat('MMM dd, yyyy').format(expense.expenseDate),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                          // Description if available
                          if (expense.description != null && expense.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              expense.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Actions
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onTap();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
