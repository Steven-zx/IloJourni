import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';
import '../services/saved_trips_store.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});
  static const route = '/itinerary';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Your Iloilo Adventure Awaits')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Here's your personalized itinerary", style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black54)),
          const SizedBox(height: 12),
          _SummaryRow(),
          const SizedBox(height: 16),
          _DayHeader(day: 'Day 1', subtitle: '2 activities planned'),
          const SizedBox(height: 12),
          _PlaceCard(
            title: 'Jaro Cathedral',
            image: 'assets/images/jaroCathedral.jpg',
            imageColor: const Color(0xFFE8B86D),
            description: 'Start your day with a visit to Jaro Cathedral, one of Iloilo\'s most historic churches known for its grand architecture and the miraculous Our Lady of Candles.',
            time: '1 hour', location: 'Jaro, Iloilo City', price: 'Free Entry', tags: const ['Culture', 'Arts'],
          ),
          const SizedBox(height: 12),
          const SizedBox(width: double.infinity, child: _RideSegment(line: 'Ride: Ungka', details: 'Jeep • E-Bus   2-3 hours   Fare: ₱ 15')),
          const SizedBox(height: 12),
          _PlaceCard(
            title: "Netong's",
            image: 'assets/images/netongsBatchoy.jpg',
            imageColor: const Color(0xFFE67E22),
            description: 'Grab brunch at Netong\'s, the home of the original La Paz Batchoy — a comforting bowl of Ilonggo goodness.',
            time: '1 hour', location: 'La Paz Public Market', price: '₱ 150-200', tags: const ['Culture', 'Arts'],
          ),
          const SizedBox(height: 12),
          const SizedBox(width: double.infinity, child: _RideSegment(line: 'Ride: Villa / Mohon / Molo', details: 'Jeep • E-Bus   15-20min   Fare: ₱ 15-20')),
          const SizedBox(height: 12),
          _PlaceCard(
            title: 'Molo Church',
            image: 'assets/images/moloChurch.jpg',
            imageColor: const Color(0xFFCD9A5B),
            description: "Visit Iloilo's iconic Gothic Revival church, home to the miraculous Our Lady of Candles.",
            time: '2 hours', location: 'Molo, Iloilo City', price: 'Free Entry', tags: const ['Culture', 'Arts'],
          ),
          const SizedBox(height: 12),
          _PlaceCard(
            title: 'Molo Mansion',
            image: 'assets/images/moloMansion.jpg',
            imageColor: const Color(0xFF8B7355),
            description: 'Right across the church, visit Molo Mansion for local souvenirs and a quick coffee stop at Café Panay.',
            time: '2 hours', location: 'Molo, Iloilo City', price: '₱ 100-200', tags: const ['Culture', 'Arts'],
          ),
          const SizedBox(height: 12),
          _PlaceCard(
            title: 'Esplanade Walk',
            image: 'assets/images/esplanadeWalk.jpg',
            imageColor: const Color(0xFF27AE60),
            description: 'Enjoy a peaceful sunset stroll at the Iloilo River Esplanade — perfect for nature lovers and photo ops.',
            time: '2 hours', location: 'Mandurriao', price: 'Free Entry', tags: const ['Culture', 'Arts'],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('Plan Again'),
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
                    // Navigate back to home and show success message
                    Navigator.popUntil(context, (route) => route.settings.name == '/home');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Itinerary saved! View it in Saved Trips.'),
                        backgroundColor: AppTheme.teal,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal, shape: const StadiumBorder()),
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

class _SummaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
            child: Column(children: [Icon(icon, color: AppTheme.navy), const SizedBox(height: 6), Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]),
          ),
        );
    return SizedBox(
      width: double.infinity,
      child: Row(children: [item(Icons.schedule, 'Duration', '1 Day'), const SizedBox(width: 8), item(Icons.place_outlined, 'Places', '7 Spots'), const SizedBox(width: 8), item(Icons.payments_outlined, 'Budget', '₱ 3000')]),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.subtitle});
  final String day;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black87)), child: Text(day, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ]),
    ]);
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.title, required this.image, this.imageColor, required this.description, required this.time, required this.location, required this.price, required this.tags});
  final String title;
  final String image;
  final Color? imageColor;
  final String description;
  final String time;
  final String location;
  final String price;
  final List<String> tags;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), 
          child: image.isEmpty
            ? PlaceholderImage(height: 140, width: double.infinity, label: title, color: imageColor)
            : Image.asset(image, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 140, color: AppTheme.lightGrey)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(description, style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black87)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule, size: 18, color: Colors.black54), const SizedBox(width: 4), Text(time), const SizedBox(width: 12),
              const Icon(Icons.place_outlined, size: 18, color: Colors.black54), const SizedBox(width: 4), Text(location), const SizedBox(width: 12),
              const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.black54), const SizedBox(width: 4), Text(price),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black26)), child: Text(t))).toList()),
          ]),
        )
      ]),
    );
  }
}

class _RideSegment extends StatelessWidget {
  const _RideSegment({required this.line, required this.details});
  final String line;
  final String details;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(children: [const Icon(Icons.directions_car), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(line, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(details, style: const TextStyle(color: Colors.black54))]))]),
    );
  }
}
