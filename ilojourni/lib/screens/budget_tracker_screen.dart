import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/saved_trips_store.dart';
import '../models/destination.dart';

class BudgetTrackerScreen extends StatefulWidget {
  const BudgetTrackerScreen({super.key});
  static const route = '/budget';

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  SavedTrip? _selectedTrip;
  int _additionalExpenses = 0;

  @override
  void initState() {
    super.initState();
    // Auto-select first trip if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trips = SavedTripsStore.instance.trips;
      if (trips.isNotEmpty && _selectedTrip == null) {
        setState(() => _selectedTrip = trips.first);
      }
    });
  }

  void _addExpensePrompt() async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final amount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Amount (₱)',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkBackground : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final v = int.tryParse(controller.text.trim());
                        if (v != null && v > 0) Navigator.pop(ctx, v);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
    if (amount != null) setState(() => _additionalExpenses += amount);
  }

  void _selectTrip() async {
    final trips = SavedTripsStore.instance.trips;
    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved trips. Create one first!')),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showModalBottomSheet<SavedTrip>(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Trip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: trips.length,
                itemBuilder: (ctx, index) {
                  final trip = trips[index];
                  return ListTile(
                    title: Text(
                      trip.itinerary.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${trip.itinerary.days.length} days • ₱${trip.itinerary.totalCost}',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                    trailing: trip == _selectedTrip
                        ? Icon(
                            Icons.check_circle,
                            color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, trip),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedTrip = selected;
        _additionalExpenses = 0; // Reset additional expenses when switching trips
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_selectedTrip == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Budget Tracker'),
          backgroundColor: isDark ? AppTheme.darkCard : AppTheme.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: isDark ? Colors.white24 : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No trip selected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a trip to start tracking your budget',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final itinerary = _selectedTrip!.itinerary;
    final planned = itinerary.totalBudget;
    final itineraryCost = itinerary.totalCost;
    final spent = itineraryCost + _additionalExpenses;
    final remaining = (planned - spent).clamp(0, planned);
    final progress = planned == 0 ? 0.0 : (spent / planned).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Trip',
            onPressed: _selectTrip,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip title
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itinerary.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${itinerary.days.length} days • ${_getAllActivities().length} activities',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SummaryBudget(
            planned: planned,
            spent: spent,
            remaining: remaining,
            progress: progress,
            isDark: isDark,
            itineraryCost: itineraryCost,
            additionalExpenses: _additionalExpenses,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addExpensePrompt,
              icon: const Icon(Icons.add),
              label: const Text('Add Other Expenses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                shape: const StadiumBorder(),
                elevation: 4,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Days breakdown
          ...itinerary.days.map((day) {
            final dayActivities = day.activities
                .where((a) => a.type == 'destination' || a.type == 'meal')
                .toList();
            
            return Column(
              children: [
                _DayHeader(
                  day: 'Day ${day.dayNumber}',
                  subtitle: '${dayActivities.length} activities • ₱${day.totalCost}',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...day.activities.map((activity) {
                  if (activity.type == 'transport') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RideRow(
                        line: activity.name,
                        details: '${activity.description} • ₱${activity.cost}',
                        isDark: isDark,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BudgetPlaceCard(
                        activity: activity,
                        isDark: isDark,
                      ),
                    );
                  }
                }).toList(),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Activity> _getAllActivities() {
    if (_selectedTrip == null) return [];
    return _selectedTrip!.itinerary.days
        .expand((day) => day.activities)
        .toList();
  }
}

class _SummaryBudget extends StatelessWidget {
  const _SummaryBudget({
    required this.planned,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.isDark,
    required this.itineraryCost,
    required this.additionalExpenses,
  });
  
  final int planned;
  final int spent;
  final int remaining;
  final double progress;
  final bool isDark;
  final int itineraryCost;
  final int additionalExpenses;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining Budget',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱$remaining',
                      style: TextStyle(
                        color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of ₱$planned total',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                      backgroundColor: isDark ? const Color(0xFF2A2A2A) : AppTheme.lightGrey,
                      strokeWidth: 6,
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₱$itineraryCost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Itinerary Cost',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₱$additionalExpenses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Extra Expenses',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.subtitle,
    required this.isDark,
  });
  
  final String day;
  final String subtitle;
  final bool isDark;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? AppTheme.darkTeal : AppTheme.teal).withOpacity(.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetPlaceCard extends StatelessWidget {
  const _BudgetPlaceCard({
    required this.activity,
    required this.isDark,
  });
  
  final Activity activity;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final hasImage = activity.image?.isNotEmpty ?? false;
    final location = activity.location ?? 'N/A';
    final tags = activity.tags ?? [];
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                activity.image!,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 130,
                  color: isDark ? const Color(0xFF2A2A2A) : AppTheme.lightGrey,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.cost == 0 ? 'Free' : '₱${activity.cost}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                      ),
                    ),
                  ],
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideRow extends StatelessWidget {
  const _RideRow({
    required this.line,
    required this.details,
    required this.isDark,
  });
  
  final String line;
  final String details;
  final bool isDark;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(
            Icons.directions_car,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
