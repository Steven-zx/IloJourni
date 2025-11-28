import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';
import 'trip_budget_tracker_screen.dart';
import 'trip_map_view.dart';
import '../data/destinations_database.dart';
import '../services/saved_trips_store.dart';
import '../models/destination.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});
  static const route = '/trip-detail';

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  String _selectedView = 'List'; // 'List' or 'Map'
  String _selectedDay = 'All';
  bool _initializedFromArgs = false;

  SavedTrip? get _trip {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is SavedTrip) return args;
    if (args is Map) {
      final trip = args['trip'];
      if (trip is SavedTrip) return trip;
    }
    return null;
  }

  GeneratedItinerary? get _itinerary => _trip?.itinerary;

  List<Widget> _buildFilteredContent(bool isDark) {
    if (_itinerary == null) return [];
    final widgets = <Widget>[];
    final days = _itinerary!.days;
    if (_selectedDay == 'All') {
      for (final day in days) {
        final nonTransportCount = day.activities.where((a) => a.type.toLowerCase() != 'transport').length;
        widgets.add(_DayHeader(day: 'Day ${day.dayNumber}', dayNumber: day.dayNumber, subtitle: '$nonTransportCount stop${nonTransportCount != 1 ? 's' : ''} • ₱${day.totalCost} total', isDark: isDark));
        widgets.add(const SizedBox(height: 12));
        int activityNumber = 0;
        for (int i = 0; i < day.activities.length; i++) {
          final act = day.activities[i];
          if (act.type.toLowerCase() == 'transport') {
            widgets.add(_TransportCard(
              title: act.name,
              description: act.description,
              location: act.location ?? '',
              price: '₱${act.cost}',
              isDark: isDark,
            ));
            widgets.add(const SizedBox(height: 12));
          } else {
            activityNumber++;
            widgets.add(_ActivityCard(
              number: activityNumber,
              day: day.dayNumber,
              title: act.name,
              image: act.image ?? '',
              imageColor: const Color(0xFFE8B86D),
              description: act.description,
              time: act.time,
              location: act.location ?? '',
              price: '₱ ${act.cost}',
              tags: act.tags ?? [],
              isDark: isDark,
            ));
            widgets.add(const SizedBox(height: 12));
          }
        }
      }
    } else {
      final dayNumber = int.parse(_selectedDay.split(' ')[1]);
      final day = days.firstWhere((d) => d.dayNumber == dayNumber, orElse: () => days.first);
      final nonTransportCount = day.activities.where((a) => a.type.toLowerCase() != 'transport').length;
      widgets.add(_DayHeader(day: 'Day ${day.dayNumber}', dayNumber: day.dayNumber, subtitle: '$nonTransportCount stop${nonTransportCount != 1 ? 's' : ''} • ₱${day.totalCost} total', isDark: isDark));
      widgets.add(const SizedBox(height: 12));
      int activityNumber = 0;
      for (int i = 0; i < day.activities.length; i++) {
        final act = day.activities[i];
        if (act.type.toLowerCase() == 'transport') {
          widgets.add(_TransportCard(
            title: act.name,
            description: act.description,
            location: act.location ?? '',
            price: '₱${act.cost}',
            isDark: isDark,
          ));
          widgets.add(const SizedBox(height: 12));
        } else {
          activityNumber++;
          widgets.add(_ActivityCard(
            number: activityNumber,
            day: day.dayNumber,
            title: act.name,
            image: act.image ?? '',
            imageColor: const Color(0xFFE8B86D),
            description: act.description,
            time: act.time,
            location: act.location ?? '',
            price: '₱ ${act.cost}',
            tags: act.tags ?? [],
            isDark: isDark,
          ));
          widgets.add(const SizedBox(height: 12));
        }
      }
    }
    return widgets;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final initialView = args['initialView'];
      final initialDay = args['initialDay'];
      setState(() {
        if (initialView is String && (initialView == 'List' || initialView == 'Map')) {
          _selectedView = initialView;
        }
        if (initialDay is String) {
          _selectedDay = initialDay;
        }
        _initializedFromArgs = true;
      });
    } else {
      _initializedFromArgs = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final trip = _trip;
    final itinerary = _itinerary;
    final tripTitle = trip?.title ?? itinerary?.title ?? 'Trip';
    final tripDays = itinerary?.days.length ?? 1;
    // Count only destination activities as "Spots"
    final tripSpots = itinerary?.days.fold<int>(0, (sum, d) =>
      sum + d.activities.where((a) => a.type.toLowerCase() == 'destination').length
    ) ?? 0;
    final tripTotalCost = itinerary?.totalCost ?? 0;

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
                            tripTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  // View toggle buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ViewButton(
                            label: 'List View',
                            icon: Icons.view_list,
                            isSelected: _selectedView == 'List',
                            onTap: () => setState(() => _selectedView = 'List'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ViewButton(
                            label: 'Map View',
                            icon: Icons.map_outlined,
                            isSelected: _selectedView == 'Map',
                            onTap: () => setState(() => _selectedView = 'Map'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Summary cards
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
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          _SummaryItem(icon: Icons.calendar_today, label: 'Duration', value: '$tripDays Day${tripDays > 1 ? 's' : ''}', isDark: isDark),
                          _SummaryItem(icon: Icons.place, label: 'Spots', value: '$tripSpots', isDark: isDark),
                          _SummaryItem(icon: Icons.payments, label: 'Total Cost', value: '₱$tripTotalCost', isDark: isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Day filter chips and content
          if (_selectedView == 'List') ...[
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
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
                  ...List.generate(
                    itinerary?.days.length ?? 0,
                    (i) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _DayChip(
                        label: 'Day ${i + 1}',
                        isSelected: _selectedDay == 'Day ${i + 1}',
                        onTap: () => setState(() => _selectedDay = 'Day ${i + 1}'),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: _buildFilteredContent(isDark),
              ),
            ),
          ]
          else ...[
            // Map View
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
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
                  ...List.generate(
                    itinerary?.days.length ?? 0,
                    (i) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _DayChip(
                        label: 'Day ${i + 1}',
                        isSelected: _selectedDay == 'Day ${i + 1}',
                        onTap: () => setState(() => _selectedDay = 'Day ${i + 1}'),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TripMapView(
                itinerary: itinerary,
                destinations: DestinationsDatabase.allDestinations,
                selectedDay: _selectedDay,
              ),
            ),
          ],
          // Budget Tracker Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, TripBudgetTrackerScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Budget Tracker',
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

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkCard : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? AppTheme.darkTeal : AppTheme.teal)
                  : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : AppTheme.teal)
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isDark ? AppTheme.darkTeal : AppTheme.teal, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkCard : Colors.white)
              : (isDark ? const Color(0xFF1A3A47) : const Color(0xFF2D7A6E)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.4)),
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
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.dayNumber,
    required this.subtitle,
    required this.isDark,
  });

  final String day;
  final int dayNumber;
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
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.number,
    required this.day,
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
  final int day;
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
    // Fallback: if image is empty, try lookup by name in DestinationsDatabase
    String resolvedImage = image;
    if (resolvedImage.isEmpty) {
      try {
        final match = DestinationsDatabase.allDestinations.firstWhere(
          (d) => d.name.toLowerCase() == title.toLowerCase(),
          orElse: () => DestinationsDatabase.allDestinations.firstWhere(
            (d) => d.name.toLowerCase().contains(title.toLowerCase()),
            orElse: () => DestinationsDatabase.allDestinations.first,
          ),
        );
        if (match.image.isNotEmpty) {
          resolvedImage = match.image;
        }
      } catch (_) {}
    }
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: resolvedImage.isEmpty
                    ? PlaceholderImage(
                        height: 150,
                        width: double.infinity,
                        label: title,
                        color: imageColor,
                      )
                    : Image.asset(
                        resolvedImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
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
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[700])),
                    const SizedBox(width: 12),
                    Icon(Icons.place_outlined, size: 16, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.payments_outlined, size: 16, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(price, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
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

class _TransportCard extends StatelessWidget {
  const _TransportCard({
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.isDark,
  });

  final String title;
  final String description;
  final String location;
  final String price;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
