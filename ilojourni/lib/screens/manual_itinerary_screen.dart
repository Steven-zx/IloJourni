import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/saved_trips_store.dart';
import '../models/destination.dart';
import '../data/destinations_database.dart';
import 'more_info_screen.dart';
import 'trip_detail_screen.dart';

class ItineraryDay {
  final int dayNumber;
  final List<DestinationItem> destinations;

  ItineraryDay({required this.dayNumber, this.destinations = const []});

  ItineraryDay copyWith({List<DestinationItem>? destinations}) {
    return ItineraryDay(
      dayNumber: dayNumber,
      destinations: destinations ?? this.destinations,
    );
  }
}

class DestinationItem {
  final String id;
  final String name;
  final String district;
  final String category;
  final String image;

  const DestinationItem({
    required this.id,
    required this.name,
    required this.district,
    required this.category,
    required this.image,
  });
}

class ManualItineraryScreen extends StatefulWidget {
  const ManualItineraryScreen({super.key});
  static const route = '/manual-itinerary';

  @override
  State<ManualItineraryScreen> createState() => _ManualItineraryScreenState();
}

class _ManualItineraryScreenState extends State<ManualItineraryScreen> {
  final TextEditingController _titleController = TextEditingController(text: 'My Custom Iloilo Trip');
  final TextEditingController _budgetController = TextEditingController(text: '0');
  List<ItineraryDay> days = [
    ItineraryDay(dayNumber: 1),
  ];
  int selectedDayIndex = 0;
  final Map<int, bool> _expandedDays = {0: true};
  final ScrollController _daysScrollController = ScrollController();

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _daysScrollController.dispose();
    super.dispose();
  }

  // Basic jeepney fare heuristic: intra-city ≈ ₱15, cross-district ≈ ₱30, far (San Joaquin/Miag-ao) ≈ ₱50
  int _estimateJeepneyFare(String from, String to) {
    final f = from.toLowerCase();
    final t = to.toLowerCase();
    if (f == t) return 15;
    const inner = ['iloilo city', 'mandurriao', 'la paz', 'molo', 'city proper', 'jaro'];
    final isInner = inner.contains(f) && inner.contains(t);
    if (isInner) return 15;
    if ((f.contains('san joaquin') || f.contains('miag')) || (t.contains('san joaquin') || t.contains('miag')))
      return 50;
    return 30;
  }
  void _addDestinationToDay(DestinationItem destination) {
    setState(() {
      final updatedDestinations = List<DestinationItem>.from(days[selectedDayIndex].destinations)
        ..add(destination);
      days[selectedDayIndex] = days[selectedDayIndex].copyWith(destinations: updatedDestinations);
    });
  }

  void _removeDestinationFromDay(int dayIndex, int destinationIndex) {
    setState(() {
      final updatedDestinations = List<DestinationItem>.from(days[dayIndex].destinations)
        ..removeAt(destinationIndex);
      days[dayIndex] = days[dayIndex].copyWith(destinations: updatedDestinations);
    });
  }

  void _addDay() {
    setState(() {
      final newDayIndex = days.length;
      days.add(ItineraryDay(dayNumber: days.length + 1));
      // Auto-expand the newly added day for quicker editing
      _expandedDays[newDayIndex] = true;
    });
    // Auto-select and scroll to the newly added day
    setState(() => selectedDayIndex = days.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_daysScrollController.hasClients) {
        _daysScrollController.animateTo(
          _daysScrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _removeDay(int index) {
    if (days.length > 1) {
      setState(() {
        days.removeAt(index);
        _expandedDays.remove(index);
        // Renumber days and update expanded map
        final newExpandedDays = <int, bool>{};
        for (int i = 0; i < days.length; i++) {
          days[i] = ItineraryDay(dayNumber: i + 1, destinations: days[i].destinations);
          newExpandedDays[i] = _expandedDays[i + (i >= index ? 1 : 0)] ?? false;
        }
        _expandedDays.clear();
        _expandedDays.addAll(newExpandedDays);
        if (selectedDayIndex >= days.length) {
          selectedDayIndex = days.length - 1;
        }
      });
    }
  }

  void _toggleDayExpansion(int index) {
    setState(() {
      _expandedDays[index] = !(_expandedDays[index] ?? false);
    });
  }

  int _getTotalDestinations() {
    return days.fold(0, (sum, day) => sum + day.destinations.length);
  }

  // Reusable cost calculator matching logic used in itinerary creation
  int _calculateDestinationCost(DestinationItem dest) {
    final dbItem = DestinationsDatabase.getById(dest.id);
    int cost = dbItem?.entranceFee ?? 0; // base entrance
    switch (dest.category.toLowerCase()) {
      case 'food': // specific known establishments overrides
        if (dest.id == 'netongs-batchoy') return 200;
        if (dest.id == 'robertos-siopao') return 150;
        if (dest.id == 'breakthrough-restaurant') return 450;
        if (dest.id == 'madge-cafe') return 120;
        return 200; // default meal estimate
      case 'leisure':
        return cost; // promenades typically free
      case 'nature':
        if (dbItem != null && dbItem.entranceFee > 0) return dbItem.entranceFee;
        if (dest.id == 'isla-higantes') return 100; // environmental/local fee
        if (dest.id == 'guimaras-island') return 0; // open access
        return 50; // modest default
      case 'culture':
        return dbItem?.entranceFee ?? 0;
      case 'shopping':
        return 0; // user-driven spend not auto-estimated
      default:
        return cost;
    }
  }

  int _computeTotalCost() {
    return days.fold(0, (sum, day) => sum + day.destinations.fold(0, (dSum, dest) => dSum + _calculateDestinationCost(dest)));
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DestinationPickerSheet(
        onDestinationSelected: _addDestinationToDay,
      ),
    );
  }

  void _createItinerary() {
    if (_getTotalDestinations() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one destination')),
      );
      return;
    }

    final budget = int.tryParse(_budgetController.text) ?? 0;
    // Build days with computed activity costs and totals
    final manualDays = days.map((day) {
      final List<Activity> activities = [];
      for (int i = 0; i < day.destinations.length; i++) {
        final dest = day.destinations[i];
        final cost = _calculateDestinationCost(dest);
        activities.add(Activity(
          type: 'destination',
          name: dest.name,
          description: dest.name,
          time: 'TBD',
          cost: cost,
          location: dest.district,
          tags: [dest.category],
          image: dest.image,
        ));
        if (i < day.destinations.length - 1) {
          final next = day.destinations[i + 1];
          final hopFare = _estimateJeepneyFare(dest.district, next.district);
          activities.add(Activity(
            type: 'transport',
            name: 'Jeepney to ${next.name}',
            description: 'Travel via jeepney to ${next.district}',
            time: 'TBD',
            cost: hopFare,
            location: '${dest.district} → ${next.district}',
            tags: const ['Transport'],
            image: '',
          ));
        }
      }
      final totalCost = activities.fold<int>(0, (sum, a) => sum + a.cost);
      return DayPlan(
        dayNumber: day.dayNumber,
        theme: 'Day ${day.dayNumber}',
        activities: activities,
        totalCost: totalCost,
      );
    }).toList();

    final itineraryTotalCost = manualDays.fold<int>(0, (sum, d) => sum + d.totalCost);
    final manualItinerary = GeneratedItinerary(
      title: _titleController.text,
      totalBudget: budget,
      totalCost: itineraryTotalCost,
      summary: 'Custom manually created itinerary',
      days: manualDays,
    );

    // Save to SavedTripsStore and navigate with the saved trip as argument
    final savedTrip = SavedTrip(
      title: _titleController.text,
      dateRange: 'Custom Trip • ${days.length} day${days.length == 1 ? '' : 's'}',
      budget: budget,
      image: days.first.destinations.isNotEmpty ? days.first.destinations.first.image : '',
      itinerary: manualItinerary,
    );
    SavedTripsStore.add(savedTrip);

    // Navigate to TripDetailScreen with trip data so summary is populated
    Navigator.pushReplacementNamed(
      context,
      TripDetailScreen.route,
      arguments: {
        'trip': savedTrip,
        'initialView': 'List',
        'initialDay': 'Day ${days.length}',
      },
    );
    
    // Show success message
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Itinerary created and saved to trips!'),
            backgroundColor: AppTheme.teal,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalDestinations = _getTotalDestinations();
    final totalCost = _computeTotalCost();

    // Screen width can be used for future responsive adjustments
    // final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header section
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Build Your Itinerary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Title input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey[800],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'My Custom Iloilo Trip',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCard : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Summary stats
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBadge(icon: Icons.calendar_today, value: '${days.length} Day${days.length > 1 ? 's' : ''}', label: 'Duration', isDark: isDark),
                          _StatBadge(icon: Icons.place, value: '$totalDestinations', label: 'Spots', isDark: isDark),
                          _StatBadge(icon: Icons.payments, value: '₱$totalCost', label: 'Total Cost', isDark: isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Day tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DayChip(
                    label: 'All',
                    isSelected: selectedDayIndex == -1,
                    onTap: () => setState(() => selectedDayIndex = -1),
                    isDark: isDark,
                  ),
                  ...days.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _DayChip(
                        label: 'Day ${index + 1}',
                        isSelected: selectedDayIndex == index,
                        onTap: () => setState(() => selectedDayIndex = index),
                        isDark: isDark,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Days list
          Expanded(
            child: ListView.builder(
              controller: _daysScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isExpanded = _expandedDays[index] ?? false;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DayCard(
                    day: day,
                    isExpanded: isExpanded,
                    onToggle: () => _toggleDayExpansion(index),
                    onAddDestination: () {
                      setState(() => selectedDayIndex = index);
                      _showDestinationPicker();
                    },
                    onRemoveDestination: (destIndex) => _removeDestinationFromDay(index, destIndex),
                    onDeleteDay: () => _removeDay(index),
                    canDelete: days.length > 1,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addDay,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? AppTheme.darkAccent : AppTheme.teal, width: 1.5),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(Icons.add, color: isDark ? AppTheme.darkAccent : AppTheme.teal),
                    label: Text('Add Another Day', style: TextStyle(color: isDark ? AppTheme.darkAccent : AppTheme.teal, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _createItinerary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text('Create Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DayChip({required this.label, required this.isSelected, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkTeal : AppTheme.teal)
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(25),
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
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final ItineraryDay day;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAddDestination;
  final Function(int) onRemoveDestination;
  final VoidCallback onDeleteDay;
  final bool canDelete;
  final bool isDark;

  const _DayCard({
    required this.day,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddDestination,
    required this.onRemoveDestination,
    required this.onDeleteDay,
    required this.canDelete,
    required this.isDark,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<DestinationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<DestinationItem>.from(widget.day.destinations);
  }

  @override
  void didUpdateWidget(covariant _DayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = _items;
    final current = widget.day.destinations;
    // Handle addition
    if (current.length > previous.length) {
      final index = current.length - 1; // assume append
      final newItem = current[index];
      _items.insert(index, newItem);
      _listKey.currentState?.insertItem(index, duration: const Duration(milliseconds: 250));
    }
    // Handle single removal at an index
    else if (current.length < previous.length) {
      int removalIndex = current.length; // default to end
      for (int i = 0; i < previous.length; i++) {
        if (i >= current.length || previous[i].id != current[i].id) {
          removalIndex = i;
          break;
        }
      }
      final removedItem = _items.removeAt(removalIndex);
      _listKey.currentState?.removeItem(
        removalIndex,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _DestinationCard(destination: removedItem, onRemove: () {}),
        ),
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final isExpanded = widget.isExpanded;
    final isDark = widget.isDark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkTeal : AppTheme.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Day header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.dayNumber}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${day.dayNumber}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        Text(
                          '${day.destinations.length} destination${day.destinations.length != 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (widget.canDelete)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: widget.onDeleteDay,
                    ),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    onPressed: widget.onToggle,
                  ),
                ],
              ),
            ),
          ),
          // Day content
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_items.isEmpty)
                    Column(
                      children: [
                        const Icon(Icons.place, color: Colors.grey, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No destinations yet',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add your first stop to get started',
                          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  else
                    AnimatedList(
                      key: _listKey,
                      initialItemCount: _items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index, animation) {
                        final dest = _items[index];
                        return SizeTransition(
                          sizeFactor: animation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DestinationCard(
                              destination: dest,
                              onRemove: () => widget.onRemoveDestination(index),
                            ),
                          ),
                        );
                      },
                    ),
                  // Add destination button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAddDestination,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? AppTheme.darkAccent : AppTheme.teal, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.add, color: isDark ? AppTheme.darkAccent : AppTheme.teal),
                      label: Text(
                        'Add Destination',
                        style: TextStyle(color: isDark ? AppTheme.darkAccent : AppTheme.teal, fontWeight: FontWeight.w600),
                      ),
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

class _DestinationCard extends StatelessWidget {
  final DestinationItem destination;
  final VoidCallback onRemove;

  const _DestinationCard({required this.destination, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Locations that have full detail pages
    final availableLocations = ['molo-church', 'jaro-cathedral', 'esplanade', 'molo-mansion', 'netongs-batchoy'];
    final hasDetails = availableLocations.contains(destination.id);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // print('Card tapped! ID: ${destination.id}, Has details: $hasDetails');
          if (hasDetails) {
            // print('Navigating to MoreInfoScreen with ID: ${destination.id}');
            Navigator.pushNamed(
              context,
              MoreInfoScreen.route,
              arguments: destination.id,
            );
          } else {
            // print('Showing snackbar for: ${destination.name}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Full details for ${destination.name} coming soon!'),
                backgroundColor: AppTheme.teal,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.asset(
                  destination.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.teal.withOpacity(0.3),
                    child: const Icon(Icons.place, color: AppTheme.teal),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${destination.district} • ${destination.category}',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54, size: 20),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationPickerSheet extends StatefulWidget {
  final Function(DestinationItem) onDestinationSelected;

  const _DestinationPickerSheet({required this.onDestinationSelected});

  @override
  State<_DestinationPickerSheet> createState() => _DestinationPickerSheetState();
}

class _DestinationPickerSheetState extends State<_DestinationPickerSheet> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> categories = ['All', 'Foodie', 'Nature', 'Culture', 'Adventure', 'Arts', 'Budget', 'Chill'];
  
  final List<DestinationItem> allDestinations = const [
    DestinationItem(
      id: 'jaro-cathedral',
      name: 'Jaro Cathedral',
      district: 'Jaro District',
      category: 'Culture',
      image: 'assets/images/jaroCathedral.jpg',
    ),
    DestinationItem(
      id: 'molo-church',
      name: 'Molo Church',
      district: 'Molo District',
      category: 'Culture',
      image: 'assets/images/moloChurch.jpg',
    ),
    DestinationItem(
      id: 'isla-higantes',
      name: 'Isla de Gigantes',
      district: 'Carles',
      category: 'Nature',
      image: 'assets/images/islan higantes.png',
    ),
    DestinationItem(
      id: 'guimaras-island',
      name: 'Guimaras Island',
      district: 'Guimaras',
      category: 'Nature',
      image: 'assets/images/guimarasIsland.jpg',
    ),
    DestinationItem(
      id: 'netongs-batchoy',
      name: "Netong's Batchoy",
      district: 'La Paz',
      category: 'Food',
      image: 'assets/images/netongsBatchoy.jpg',
    ),
    DestinationItem(
      id: 'breakthrough-restaurant',
      name: 'Breakthrough Restaurant',
      district: 'Villa Beach',
      category: 'Food',
      image: 'assets/images/breakthrough.jpg',
    ),
    DestinationItem(
      id: 'esplanade-walk',
      name: 'Iloilo Esplanade',
      district: 'Iloilo City',
      category: 'Leisure',
      image: 'assets/images/esplanadeWalk.jpg',
    ),
    DestinationItem(
      id: 'miagao-church',
      name: 'Miag-ao Church',
      district: 'Mieg-ao',
      category: 'Culture',
      image: 'assets/images/miagaoChurch.jpg',
    ),
    DestinationItem(
      id: 'garin-farm',
      name: 'Garin Farm',
      district: 'San Joaquin',
      category: 'Nature',
      image: 'assets/images/garinFarm.jpg',
    ),
    DestinationItem(
      id: 'museo-iloilo',
      name: 'Museo Iloilo',
      district: 'Iloilo City',
      category: 'Culture',
      image: 'assets/images/museoIloilo.jpg',
    ),
    DestinationItem(
      id: 'robertos-siopao',
      name: "Roberto's Siopao",
      district: 'Iloilo City',
      category: 'Food',
      image: 'assets/images/robertos.png',
    ),
    DestinationItem(
      id: 'smallville-complex',
      name: 'Smallville Complex',
      district: 'Mandurriao',
      category: 'Leisure',
      image: 'assets/images/smallville.png',
    ),
    DestinationItem(
      id: 'madge-cafe',
      name: 'Madge Café',
      district: 'Iloilo City',
      category: 'Food',
      image: 'assets/images/madgeCafe.png',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DestinationItem> get filteredDestinations {
    var filtered = allDestinations;
    
    if (selectedCategory != 'All') {
      filtered = filtered.where((dest) => 
        dest.category.toLowerCase() == selectedCategory.toLowerCase()
      ).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((dest) =>
        dest.name.toLowerCase().contains(query) ||
        dest.district.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Choose Destination',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey),
                filled: true,
                fillColor: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          // Category chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => selectedCategory = category),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? (isDark ? AppTheme.darkTeal : AppTheme.teal)
                            : (isDark ? AppTheme.darkCard : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Destinations list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredDestinations.length,
              itemBuilder: (context, index) {
                final destination = filteredDestinations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      widget.onDestinationSelected(destination);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: destination.image.isNotEmpty
                                ? Image.asset(
                                    destination.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppTheme.teal.withOpacity(0.2),
                                      child: const Icon(Icons.place, color: AppTheme.teal),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: AppTheme.teal.withOpacity(0.2),
                                    child: const Icon(Icons.place, color: AppTheme.teal),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destination.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      destination.district,
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF3A3A3A) : AppTheme.teal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        destination.category,
                                        style: TextStyle(
                                          color: isDark ? AppTheme.darkAccent : AppTheme.teal,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color: isDark ? AppTheme.darkAccent : AppTheme.teal),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                MoreInfoScreen.route,
                                arguments: destination.id,
                              );
                            },
                            tooltip: 'View details',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
