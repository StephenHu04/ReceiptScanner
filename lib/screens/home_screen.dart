import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

enum SortOption {
  dateNewest,
  dateOldest,
}

enum TimeFilter {
  allTime,
  thisYear,
  last6Months,
  last3Months,
  thisMonth,
  thisWeek,
}

enum ExpenseCategory {
  groceries,
  dining,
  transportation,
  healthcare,
  clothing,
  electronics,
  homeMaintenance,
  onlineShopping,
  travel,
  entertainment,
  generalMerchandise,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ExpenseEntry> _expenses = [];
  final TextEditingController _searchController = TextEditingController();
  double _totalSpent = 0.0;
  SortOption _currentSort = SortOption.dateNewest;
  String _searchQuery = '';
  TimeFilter _currentTimeFilter = TimeFilter.allTime;

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  double get _filteredTotalSpent {
    final now = DateTime.now();
    final filteredExpenses = _expenses.where((expense) {
      switch (_currentTimeFilter) {
        case TimeFilter.allTime:
          return true;
        case TimeFilter.thisYear:
          return expense.date.year == now.year;
        case TimeFilter.last6Months:
          final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
          return expense.date.isAfter(sixMonthsAgo);
        case TimeFilter.last3Months:
          final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
          return expense.date.isAfter(threeMonthsAgo);
        case TimeFilter.thisMonth:
          return expense.date.year == now.year && expense.date.month == now.month;
        case TimeFilter.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return expense.date.isAfter(startOfWeek);
      }
    });
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  String get _timeFilterLabel {
    switch (_currentTimeFilter) {
      case TimeFilter.allTime:
        return 'All Time';
      case TimeFilter.thisYear:
        return 'This Year';
      case TimeFilter.last6Months:
        return 'Last 6 Months';
      case TimeFilter.last3Months:
        return 'Last 3 Months';
      case TimeFilter.thisMonth:
        return 'This Month';
      case TimeFilter.thisWeek:
        return 'This Week';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseEntry> get _filteredExpenses {
    if (_searchQuery.isEmpty) return _expenses;
    return _expenses.where((expense) =>
      expense.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Map<DateTime, List<ExpenseEntry>> get _groupedExpenses {
    final grouped = <DateTime, List<ExpenseEntry>>{};
    for (final expense in _filteredExpenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      grouped.putIfAbsent(date, () => []).add(expense);
    }
    
    // Sort expenses within each date group by name
    for (final expenses in grouped.values) {
      expenses.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => _currentSort == SortOption.dateNewest
            ? b.key.compareTo(a.key)
            : a.key.compareTo(b.key))
    );
  }

  void _addExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseSheet(
        onAdd: (expense) {
          setState(() {
            _expenses.add(ExpenseEntry(
              name: _capitalizeWords(expense.name),
              amount: expense.amount,
              date: expense.date,
              category: expense.category ?? ExpenseCategory.generalMerchandise,
            ));
            _totalSpent += expense.amount;
          });
        },
      ),
    );
  }

  void _removeExpense(int index) {
    setState(() {
      _totalSpent -= _expenses[index].amount;
      _expenses.removeAt(index);
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Sort by'),
            tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date (Newest)'),
            selected: _currentSort == SortOption.dateNewest,
            onTap: () {
              setState(() {
                _currentSort = SortOption.dateNewest;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date (Oldest)'),
            selected: _currentSort == SortOption.dateOldest,
            onTap: () {
              setState(() {
                _currentSort = SortOption.dateOldest;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.dining:
        return 'Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.clothing:
        return 'Clothing';
      case ExpenseCategory.electronics:
        return 'Electronics';
      case ExpenseCategory.homeMaintenance:
        return 'Home Maintenance';
      case ExpenseCategory.onlineShopping:
        return 'Online Shopping';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.generalMerchandise:
        return 'General Merchandise';
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.groceries:
        return Colors.green;
      case ExpenseCategory.dining:
        return Colors.orange;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.healthcare:
        return Colors.red;
      case ExpenseCategory.clothing:
        return Colors.purple;
      case ExpenseCategory.electronics:
        return Colors.indigo;
      case ExpenseCategory.homeMaintenance:
        return Colors.brown;
      case ExpenseCategory.onlineShopping:
        return Colors.teal;
      case ExpenseCategory.travel:
        return Colors.amber;
      case ExpenseCategory.entertainment:
        return Colors.pink;
      case ExpenseCategory.generalMerchandise:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total SPENT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<TimeFilter>(
                              value: _currentTimeFilter,
                              items: TimeFilter.values.map((filter) {
                                return DropdownMenuItem(
                                  value: filter,
                                  child: Text(_getTimeFilterLabel(filter)),
                                );
                              }).toList(),
                              onChanged: (TimeFilter? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _currentTimeFilter = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${_filteredTotalSpent.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dates = _groupedExpenses.keys.toList();
                final date = dates[index];
                final expenses = _groupedExpenses[date]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        DateFormat('MMMM dd, yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...expenses.map((expense) {
                      final originalIndex = _expenses.indexOf(expense);
                      final category = expense.category ?? ExpenseCategory.generalMerchandise;
                      return Dismissible(
                        key: Key(expense.hashCode.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Expense'),
                              content: Text(
                                'Are you sure you want to delete "${expense.name}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _removeExpense(originalIndex);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${expense.name} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  setState(() {
                                    _expenses.insert(originalIndex, expense);
                                    _totalSpent += expense.amount;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(expense.name),
                            subtitle: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getCategoryLabel(category),
                                style: TextStyle(
                                  color: _getCategoryColor(category),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            trailing: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
              childCount: _groupedExpenses.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTimeFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.allTime:
        return 'All Time';
      case TimeFilter.thisYear:
        return 'This Year';
      case TimeFilter.last6Months:
        return 'Last 6 Months';
      case TimeFilter.last3Months:
        return 'Last 3 Months';
      case TimeFilter.thisMonth:
        return 'This Month';
      case TimeFilter.thisWeek:
        return 'This Week';
    }
  }
}

class AddExpenseSheet extends StatefulWidget {
  final Function(ExpenseEntry) onAdd;

  const AddExpenseSheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _amountError;
  ExpenseCategory _selectedCategory = ExpenseCategory.generalMerchandise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              border: const OutlineInputBorder(),
              prefixText: '\$',
              errorText: _amountError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _amountError = null;
                } else if (double.tryParse(value) == null) {
                  _amountError = 'Please enter a valid number';
                } else if (double.parse(value) <= 0) {
                  _amountError = 'Amount must be greater than 0';
                } else {
                  _amountError = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryLabel(category)),
              );
            }).toList(),
            onChanged: (ExpenseCategory? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: const Text('Select Date'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }
              
              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              widget.onAdd(
                ExpenseEntry(
                  name: _nameController.text,
                  amount: amount,
                  date: _selectedDate,
                  category: _selectedCategory,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Add Expense'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getCategoryLabel(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.dining:
        return 'Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.clothing:
        return 'Clothing';
      case ExpenseCategory.electronics:
        return 'Electronics';
      case ExpenseCategory.homeMaintenance:
        return 'Home Maintenance';
      case ExpenseCategory.onlineShopping:
        return 'Online Shopping';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.generalMerchandise:
        return 'General Merchandise';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

class ExpenseEntry {
  final String name;
  final double amount;
  final DateTime date;
  final ExpenseCategory? category;

  ExpenseEntry({
    required this.name,
    required this.amount,
    required this.date,
    this.category,
  });
} 