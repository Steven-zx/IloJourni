import 'package:flutter/material.dart';
import '../services/saved_trips_store.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';
import 'trip_detail_screen.dart';
import 'plan_form_screen.dart';
import 'manual_itinerary_screen.dart';

class SavedTripsScreen extends StatefulWidget {
  const SavedTripsScreen({super.key});
  static const route = '/saved-trips';

  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  @override
  void initState() {
    super.initState();
    SavedTripsStore.instance.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    SavedTripsStore.instance.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTrips = SavedTripsStore.instance.trips.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Saved Trips'),
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      ),
      body: hasTrips
          ? RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() {});
              },
              color: isDark ? AppTheme.darkTeal : AppTheme.teal,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Here are your saved trips',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: SavedTripsStore.instance.trips.length,
                        itemBuilder: (context, index) {
                          final t = SavedTripsStore.instance.trips[index];
                          return _TripCard(
                            trip: t,
                            onOpen: () {
                              Navigator.pushNamed(
                                context,
                                TripDetailScreen.route,
                                arguments: t,
                              );
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                                  title: Text(
                                    'Delete Trip?',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  content: Text(
                                    'This action cannot be undone.',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await SavedTripsStore.removeAt(index);
                              }
                            },
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkTeal.withOpacity(0.1)
                            : AppTheme.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.flight_takeoff,
                        size: 60,
                        color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No trips yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start planning your first adventure\nand track your spending!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white24 : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Create a Trip',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Choose how you want to plan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _PlanOptionCard(
                                    icon: Icons.auto_awesome,
                                    title: 'AI Planning',
                                    description: 'Let AI create your perfect itinerary',
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, PlanFormScreen.route);
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  _PlanOptionCard(
                                    icon: Icons.edit_calendar,
                                    title: 'Build Manually',
                                    description: 'Create your own custom itinerary',
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, ManualItineraryScreen.route);
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Create a Trip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkTeal.withOpacity(0.2)
                                  : AppTheme.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.show_chart,
                              color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How it works',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track expenses, set budgets,\nand stay on top of your trip\nspending!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white60 : Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.onOpen,
    required this.onDelete,
    required this.isDark,
  });

  final SavedTrip trip;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final bool isDark;

  Color _getStatusColor() {
    // You can enhance this later with actual status tracking
    return const Color(0xFF2196F3); // Upcoming color
  }

  @override
  Widget build(BuildContext context) {
    final days = trip.itinerary.days.length;
    final activities = trip.itinerary.days
        .expand((day) => day.activities)
        .where((a) => a.type == 'destination')
        .length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: trip.itinerary.days.first.activities.any((a) => a.image?.isNotEmpty == true)
                    ? Image.asset(
                        trip.itinerary.days.first.activities
                            .firstWhere((a) => a.image?.isNotEmpty == true)
                            .image!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => PlaceholderImage(
                          height: 150,
                          width: double.infinity,
                          label: trip.title,
                          color: const Color(0xFF4A90E2),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      )
                    : PlaceholderImage(
                        height: 150,
                        width: double.infinity,
                        label: trip.title,
                        color: const Color(0xFF4A90E2),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Saved',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        '$days days',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 90,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 14, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        '$activities spots',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip.dateRange,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₱${trip.itinerary.totalCost}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onOpen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Trip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  const _PlanOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkTeal.withOpacity(0.2)
                    : AppTheme.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
