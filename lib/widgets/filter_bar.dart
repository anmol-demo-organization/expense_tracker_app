import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';

class FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (query) {
                  // Debounce search to avoid too many database calls
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (query == provider.searchQuery) return;
                    provider.setSearchQuery(query);
                  });
                },
              ),
              const SizedBox(height: 12),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Category filter
                    FilterChip(
                      label: Text(provider.selectedCategoryId != null
                          ? provider.getCategoryById(provider.selectedCategoryId)?.name ?? 'Category'
                          : 'All Categories'),
                      selected: provider.selectedCategoryId != null,
                      onSelected: (selected) {
                        _showCategoryFilter(context, provider);
                      },
                      avatar: provider.selectedCategoryId != null
                          ? const Icon(Icons.check, size: 16)
                          : const Icon(Icons.category, size: 16),
                    ),
                    const SizedBox(width: 8),

                    // Date filter
                    FilterChip(
                      label: Text(_getDateFilterLabel(provider)),
                      selected: provider.startDate != null || provider.endDate != null,
                      onSelected: (selected) {
                        _showDateFilter(context, provider);
                      },
                      avatar: provider.startDate != null || provider.endDate != null
                          ? const Icon(Icons.check, size: 16)
                          : const Icon(Icons.date_range, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _getDateFilterLabel(ExpenseProvider provider) {
    if (provider.startDate != null && provider.endDate != null) {
      return '${DateFormat('MMM dd').format(provider.startDate!)} - ${DateFormat('MMM dd').format(provider.endDate!)}';
    } else if (provider.startDate != null) {
      return 'From ${DateFormat('MMM dd').format(provider.startDate!)}';
    } else if (provider.endDate != null) {
      return 'Until ${DateFormat('MMM dd').format(provider.endDate!)}';
    }
    return 'All Dates';
  }

  void _showCategoryFilter(BuildContext context, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter by Category',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Categories'),
              selected: provider.selectedCategoryId == null,
              onTap: () {
                provider.setCategoryFilter(null);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ...provider.categories.map((category) {
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(int.parse(category.color.replaceFirst('#', '0xff'))),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(category.name),
                selected: provider.selectedCategoryId == category.id,
                onTap: () {
                  provider.setCategoryFilter(category.id);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showDateFilter(BuildContext context, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter by Date',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Quick date filters
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Today'),
              onTap: () {
                final today = DateTime.now();
                provider.setDateFilter(today, today);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_week),
              title: const Text('This Week'),
              onTap: () {
                final now = DateTime.now();
                final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                provider.setDateFilter(startOfWeek, now);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('This Month'),
              onTap: () {
                final now = DateTime.now();
                final startOfMonth = DateTime(now.year, now.month, 1);
                provider.setDateFilter(startOfMonth, now);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Custom Range'),
              onTap: () {
                Navigator.pop(context);
                _showCustomDateRange(context, provider);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Date Filter'),
              onTap: () {
                provider.setDateFilter(null, null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDateRange(BuildContext context, ExpenseProvider provider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
    );

    if (picked != null) {
      provider.setDateFilter(picked.start, picked.end);
    }
  }
}
