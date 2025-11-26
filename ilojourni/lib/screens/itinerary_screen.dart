import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';
import '../services/saved_trips_store.dart';
import '../models/destination.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});
  static const route = '/itinerary';

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  String _selectedDay = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    final GeneratedItinerary? itinerary = args?['itinerary'] as GeneratedItinerary?;
    final String budget = args?['budget'] as String? ?? '₱0';
    final int days = args?['days'] as int? ?? 1;
    
    // If no itinerary was generated, show error
    if (itinerary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Failed to generate itinerary. Please try again.'),
        ),
      );
    }

    final filteredDays = _selectedDay == 'All' 
        ? itinerary.days 
        : itinerary.days.where((d) => d.dayNumber.toString() == _selectedDay.replaceAll('Day ', '')).toList();
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          itinerary.title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (itinerary.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                itinerary.summary,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          _SummaryRow(
            days: days,
            totalCost: itinerary.totalCost,
            budget: itinerary.totalBudget,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          // Day filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _DayChip(
                  label: 'All', 
                  isSelected: _selectedDay == 'All', 
                  onTap: () => setState(() => _selectedDay = 'All'), 
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                ...List.generate(days, (index) {
                  final dayLabel = 'Day ${index + 1}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _DayChip(
                      label: dayLabel,
                      isSelected: _selectedDay == dayLabel,
                      onTap: () => setState(() => _selectedDay = dayLabel),
                      isDark: isDark,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Display days and activities
          ...filteredDays.map((dayPlan) {
            return Column(
              children: [
                _DayHeader(
                  day: 'Day ${dayPlan.dayNumber}',
                  subtitle: '${dayPlan.activities.length} activities • ${dayPlan.theme}',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                ...dayPlan.activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  
                  if (activity.type == 'transport') {
                    return Column(
                      children: [
                        _RideSegment(
                          line: activity.name,
                          details: '${activity.description}   Fare: ₱${activity.cost}',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }
                  
                  return Column(
                    children: [
                      _PlaceCard(
                        number: index + 1,
                        title: activity.name,
                        image: activity.image ?? 'assets/images/jaroCathedral.jpg',
                        imageColor: _getActivityColor(activity.type),
                        description: activity.description,
                        time: activity.time,
                        location: activity.location ?? '',
                        price: activity.cost == 0 ? 'Free' : '₱${activity.cost}',
                        tags: activity.tags ?? [],
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                  ),
                  child: Text(
                    'Plan Again',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    SavedTripsStore.add(SavedTrip(
                      title: itinerary.title,
                      dateRange: _generateDateRange(days),
                      budget: itinerary.totalCost,
                      image: '',
                    ));
                    Navigator.popUntil(context, (route) => route.settings.name == '/home');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Itinerary saved! View it in Saved Trips.'),
                        backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save this Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'destination':
        return const Color(0xFF4A90E2);
      case 'meal':
        return const Color(0xFFE67E22);
      case 'transport':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF2C3E50);
    }
  }

  String _generateDateRange(int days) {
    final now = DateTime.now();
    final start = now.add(const Duration(days: 7)); // Trip starts next week
    final end = start.add(Duration(days: days - 1));
    
    final formatter = DateFormat('MMMM d');
    return '${formatter.format(start)}-${formatter.format(end)}, ${end.year}';
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkTeal : AppTheme.teal)
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white24 : Colors.grey[300]!),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.days,
    required this.totalCost,
    required this.budget,
    required this.isDark,
  });
  
  final int days;
  final int totalCost;
  final int budget;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String value, {Color? valueColor}) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
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
              children: [
                Icon(icon, color: isDark ? AppTheme.darkTeal : AppTheme.navy),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
    
    final isOverBudget = totalCost > budget;
    
    return Row(
      children: [
        item(Icons.schedule, 'Duration', '$days ${days == 1 ? 'Day' : 'Days'}'),
        const SizedBox(width: 8),
        item(Icons.payments_outlined, 'Total Cost', '₱$totalCost', 
          valueColor: isOverBudget ? Colors.red : null),
        const SizedBox(width: 8),
        item(Icons.account_balance_wallet, 'Budget', '₱$budget'),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.subtitle, required this.isDark});
  final String day;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkTeal : AppTheme.teal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.number,
    required this.title,
    required this.image,
    this.imageColor,
    required this.description,
    required this.time,
    required this.location,
    required this.price,
    required this.tags,
    required this.isDark,
  });

  final int number;
  final String title;
  final String image;
  final Color? imageColor;
  final String description;
  final String time;
  final String location;
  final String price;
  final List<String> tags;
  final bool isDark;

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: image.isEmpty
                    ? PlaceholderImage(
                        height: 140,
                        width: double.infinity,
                        label: title,
                        color: imageColor,
                      )
                    : Image.asset(
                        image,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: imageColor ?? AppTheme.lightGrey,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppTheme.teal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                    const SizedBox(width: 12),
                    Icon(Icons.place_outlined, size: 18, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.chat_bubble_outline, size: 18, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(price, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey[300]!),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideSegment extends StatelessWidget {
  const _RideSegment({required this.line, required this.details, required this.isDark});
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
            blurRadius: 8,
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
              Icons.directions_car,
              color: isDark ? AppTheme.darkTeal : AppTheme.teal,
            ),
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[600],
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
