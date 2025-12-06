import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/saved_trips_store.dart';
import '../models/destination.dart';

class TripBudgetTrackerScreen extends StatefulWidget {
  const TripBudgetTrackerScreen({super.key});
  static const route = '/trip-budget-tracker';

  @override
  State<TripBudgetTrackerScreen> createState() => _TripBudgetTrackerScreenState();
}

class _TripBudgetTrackerScreenState extends State<TripBudgetTrackerScreen> {
  int _totalBudget = 0;
  int _plannedBudget = 0;
  int _spentBudget = 0;
  String _selectedDay = 'All';
  GeneratedItinerary? _itinerary;
  String _tripName = 'Trip Name';
  bool _isManualBudget = false;

  final List<BudgetItem> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      SavedTrip? trip;
      if (args is SavedTrip) {
        trip = args;
      } else if (args is Map) {
        trip = args['trip'] as SavedTrip?;
      }
      
      if (trip != null) {
        setState(() {
          _tripName = trip!.title;
          _isManualBudget = trip.budget == 0 || trip.itinerary.totalBudget == 0;
        });
        _bindItinerary(trip.itinerary);
      } else if (SavedTripsStore.instance.trips.isNotEmpty) {
        final lastTrip = SavedTripsStore.instance.trips.last;
        setState(() {
          _tripName = lastTrip.title;
          _isManualBudget = lastTrip.budget == 0 || lastTrip.itinerary.totalBudget == 0;
        });
        _bindItinerary(lastTrip.itinerary);
      }
    });
  }

  void _bindItinerary(GeneratedItinerary itin) {
    setState(() {
      _itinerary = itin;
      // For AI trips, use totalBudget if set, otherwise use totalCost as both budget and planned
      if (_isManualBudget) {
        _totalBudget = 0; // Manual trips need to set budget manually
        _plannedBudget = itin.totalCost;
      } else {
        _totalBudget = itin.totalBudget > 0 ? itin.totalBudget : itin.totalCost;
        _plannedBudget = itin.totalCost;
      }
      _items.clear();
      int activityNumber = 0;
      for (final day in itin.days) {
        for (final a in day.activities) {
          if (a.type == 'transport') {
            _items.add(BudgetItem(
              day: 'Day ${day.dayNumber}',
              type: 'transportation',
              title: a.name,
              details: '${a.description}   Fare: ₱${a.cost}',
              amount: a.cost,
              activityNumber: 0,
              location: a.location,
            ));
          } else {
            activityNumber++;
            _items.add(BudgetItem(
              day: 'Day ${day.dayNumber}',
              type: 'activity',
              title: a.name,
              details: a.location ?? '',
              amount: a.cost,
              activityNumber: activityNumber,
              location: a.location,
            ));
          }
        }
      }
      _spentBudget = 0;
    });
  }

  int get _remainingBudget => _totalBudget - _spentBudget;
  double get _progressPercent => _totalBudget == 0 ? 0 : (_spentBudget / _totalBudget).clamp(0.0, 1.0);

  int get _calculatedSpent => _items.where((i) => i.isChecked).fold(0, (sum, i) => sum + i.amount);

  List<BudgetItem> get _filteredItems {
    if (_selectedDay == 'All') return _items;
    return _items.where((i) => i.day == _selectedDay).toList();
  }

  void _toggleItem(BudgetItem item) {
    setState(() {
      item.isChecked = !item.isChecked;
      _spentBudget = _calculatedSpent;

      // Reorder: keep unchecked items at the top, move checked to bottom
      final dayLabel = item.day;
      final sameDayItems = _items.where((i) => i.day == dayLabel).toList();
      final otherItems = _items.where((i) => i.day != dayLabel).toList();
      final unchecked = sameDayItems.where((i) => !i.isChecked).toList();
      final checked = sameDayItems.where((i) => i.isChecked).toList();
      _items
        ..clear()
        ..addAll(unchecked)
        ..addAll(checked)
        ..addAll(otherItems);
    });
  }

  void _showBudgetDialog() async {
    final controller = TextEditingController(text: _totalBudget.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          title: Text('Set Budget', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter budget',
              prefixText: '₱ ',
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text.trim());
                if (amount != null && amount > 0) {
                  Navigator.pop(context, amount);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal),
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() => _totalBudget = result);
    }
  }

  void _addExpense() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddExpenseSheet(),
    );

    if (result != null) {
      setState(() {
        _spentBudget += (result['amount'] as int);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Teal header
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkTeal : AppTheme.teal,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            _tripName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isManualBudget)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                            onPressed: _showBudgetDialog,
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  // Budget summary card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Remaining Budget',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱ ${_remainingBudget.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkAccent : AppTheme.teal,
                                  ),
                                ),
                                Text(
                                  'of ₱ ${_totalBudget.toStringAsFixed(0)} total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '₱ $_spentBudget',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Spent',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white54 : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '₱ $_plannedBudget',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Planned',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white54 : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: _progressPercent,
                                  strokeWidth: 8,
                                  backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? AppTheme.darkAccent : AppTheme.teal,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '${(_progressPercent * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Day filter chips
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _DayChip(
                          label: 'All',
                          isSelected: _selectedDay == 'All',
                          onTap: () => setState(() => _selectedDay = 'All'),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        ...((_itinerary?.days ?? [])).map((d) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _DayChip(
                                label: 'Day ${d.dayNumber}',
                                isSelected: _selectedDay == 'Day ${d.dayNumber}',
                                onTap: () => setState(() => _selectedDay = 'Day ${d.dayNumber}'),
                                isDark: isDark,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                if (item.type == 'transportation') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RideCard(item: item, isDark: isDark, onToggle: () => _toggleItem(item)),
                  );
                }
                // Use the activityNumber from the item (synced with itinerary)
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BudgetItemCard(
                    number: item.activityNumber,
                    item: item,
                    isDark: isDark,
                    onToggle: () => _toggleItem(item),
                  ),
                );
              },
            ),
          ),
          // Add expense button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Add Other Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkCard : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.white : AppTheme.teal)
                : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({
    required this.item,
    required this.isDark,
    required this.onToggle,
  });

  final BudgetItem item;
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus,
              color: isDark ? AppTheme.darkTeal : AppTheme.teal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.details,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (item.amount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₱${item.amount}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          Checkbox(
            value: item.isChecked,
            onChanged: (_) => onToggle(),
            activeColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
          ),
        ],
      ),
    );
  }
}

class _BudgetItemCard extends StatelessWidget {
  const _BudgetItemCard({
    required this.number,
    required this.item,
    required this.isDark,
    required this.onToggle,
  });

  final int number;
  final BudgetItem item;
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkTeal : AppTheme.teal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                          decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.amount > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₱${item.amount}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                              decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.details,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                          decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            value: item.isChecked,
            onChanged: (_) => onToggle(),
            activeColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
          ),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Other Expenses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Amount',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixText: '₱ ',
              prefixStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final amount = int.tryParse(_controller.text.trim());
                    if (amount != null && amount > 0) {
                      Navigator.pop(context, {'amount': amount});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BudgetItem {
  final String day;
  final String type;
  final String title;
  final String details;
  final int amount;
  final int activityNumber;
  final String? location;
  bool isChecked;

  BudgetItem({
    required this.day,
    required this.type,
    required this.title,
    required this.details,
    required this.amount,
    required this.activityNumber,
    this.location,
    this.isChecked = false,
  });
}
