import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';
import '../services/saved_trips_store.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});
  static const route = '/itinerary';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Iloilo Adventure Awaits',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Here's your personalized itinerary",
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _SummaryRow(isDark: isDark),
          const SizedBox(height: 16),
          // Day filter chips
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _DayChip(label: 'All', isSelected: true, onTap: () {}, isDark: isDark),
                const SizedBox(width: 8),
                _DayChip(label: 'Day 1', isSelected: false, onTap: () {}, isDark: isDark),
                const SizedBox(width: 8),
                _DayChip(label: 'Day 2', isSelected: false, onTap: () {}, isDark: isDark),
                const SizedBox(width: 8),
                _DayChip(label: 'Day 3', isSelected: false, onTap: () {}, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DayHeader(day: 'Day 1', subtitle: '2 activities planned', isDark: isDark),
          const SizedBox(height: 12),
          _PlaceCard(
            number: 1,
            title: 'Jaro Cathedral',
            image: 'assets/images/jaroCathedral.jpg',
            imageColor: const Color(0xFFE8B86D),
            description: 'Start your day with a visit to Jaro Cathedral, one of Iloilo\'s most historic churches known for its grand architecture and the miraculous Our Lady of Candles.',
            time: '1 hour',
            location: 'Jaro, Iloilo City',
            price: 'Free Entry',
            tags: const ['Culture', 'Arts'],
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _RideSegment(line: 'Ride: Ungka', details: 'Jeep • E-Bus   2-3 hours   Fare: \u20b1 15', isDark: isDark),
          const SizedBox(height: 12),
          _PlaceCard(
            number: 2,
            title: "Netong's",
            image: 'assets/images/netongsBatchoy.jpg',
            imageColor: const Color(0xFFE67E22),
            description: 'Grab brunch at Netong\'s, the home of the original La Paz Batchoy — a comforting bowl of Ilonggo goodness.',
            time: '1 hour',
            location: 'La Paz Public Market',
            price: '\u20b1 150-200',
            tags: const ['Culture', 'Arts'],
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _RideSegment(line: 'Ride: Ungka', details: 'Jeep • E-Bus   2-3 hours   Fare: \u20b1 12-15', isDark: isDark),
          const SizedBox(height: 12),
          _PlaceCard(
            number: 3,
            title: 'Roberto\'s',
            image: 'assets/images/robertos.jpg',
            imageColor: const Color(0xFF2C3E50),
            description: 'For lunch, try Roberto\'s famous Grawn Siopao — a local favorite packed with rich flavors.',
            time: '1 hour',
            location: 'Iloilo City Proper',
            price: '\u20b1 100-250',
            tags: const ['Culture', 'Arts'],
            isDark: isDark,
          ),
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
                      title: 'Weekend Foodie Trip',
                      dateRange: 'October 13-15, 2025',
                      budget: 3000,
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
  const _SummaryRow({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String value) => Expanded(
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
    return Row(
      children: [
        item(Icons.schedule, 'Duration', '1 Day'),
        const SizedBox(width: 8),
        item(Icons.place_outlined, 'Places', '7 Spots'),
        const SizedBox(width: 8),
        item(Icons.payments_outlined, 'Budget', '\u20b1 3000'),
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
