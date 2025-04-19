import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  nameAZ,
  nameZA,
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
    return Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key))
    );
  }

  void _addExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseSheet(
        onAdd: (expense) {
          setState(() {
            _expenses.add(expense);
            _totalSpent += expense.amount;
            _sortExpenses();
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

  void _sortExpenses() {
    switch (_currentSort) {
      case SortOption.dateNewest:
        _expenses.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        _expenses.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHighest:
        _expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLowest:
        _expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.nameAZ:
        _expenses.sort((a, b) {
          final nameA = a.name.trim().toLowerCase();
          final nameB = b.name.trim().toLowerCase();
          
          for (var i = 0; i < nameA.length && i < nameB.length; i++) {
            final charA = nameA[i];
            final charB = nameB[i];
            if (charA != charB) {
              return charA.compareTo(charB);
            }
          }
          return nameA.length.compareTo(nameB.length);
        });
        break;
      case SortOption.nameZA:
        _expenses.sort((a, b) {
          final nameA = a.name.trim().toLowerCase();
          final nameB = b.name.trim().toLowerCase();
          
          for (var i = 0; i < nameA.length && i < nameB.length; i++) {
            final charA = nameA[i];
            final charB = nameB[i];
            if (charA != charB) {
              return charB.compareTo(charA);
            }
          }
          return nameB.length.compareTo(nameA.length);
        });
        break;
    }
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
                _sortExpenses();
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
                _sortExpenses();
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Amount (Highest)'),
            selected: _currentSort == SortOption.amountHighest,
            onTap: () {
              setState(() {
                _currentSort = SortOption.amountHighest;
                _sortExpenses();
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Amount (Lowest)'),
            selected: _currentSort == SortOption.amountLowest,
            onTap: () {
              setState(() {
                _currentSort = SortOption.amountLowest;
                _sortExpenses();
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Name (A-Z)'),
            selected: _currentSort == SortOption.nameAZ,
            onTap: () {
              setState(() {
                _currentSort = SortOption.nameAZ;
                _sortExpenses();
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Name (Z-A)'),
            selected: _currentSort == SortOption.nameZA,
            onTap: () {
              setState(() {
                _currentSort = SortOption.nameZA;
                _sortExpenses();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
                        const Text(
                          'Total SPENT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${_totalSpent.toStringAsFixed(2)}',
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
                                    _sortExpenses();
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
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
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
              if (_nameController.text.isNotEmpty &&
                  _amountController.text.isNotEmpty) {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                widget.onAdd(
                  ExpenseEntry(
                    name: _nameController.text,
                    amount: amount,
                    date: _selectedDate,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Expense'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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

  ExpenseEntry({
    required this.name,
    required this.amount,
    required this.date,
  });
} 