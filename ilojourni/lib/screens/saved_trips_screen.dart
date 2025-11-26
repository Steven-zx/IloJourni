import 'package:flutter/material.dart';
import '../services/saved_trips_store.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';
import 'itinerary_screen.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Trips')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Here are your saved trips', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black54))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: SavedTripsStore.instance.trips.length,
                itemBuilder: (context, index) {
                  final t = SavedTripsStore.instance.trips[index];
                  return _TripCard(
                    title: t.title,
                    date: t.dateRange,
                    budget: t.budget,
                    image: t.image,
                    onOpen: () => Navigator.pushNamed(context, ItineraryScreen.route),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Trip?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) setState(() => SavedTripsStore.removeAt(index));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.title, required this.date, required this.budget, required this.image, required this.onOpen, required this.onDelete});
  final String title;
  final String date;
  final int budget;
  final String image;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), 
          child: PlaceholderImage(
            height: 130, 
            width: double.infinity, 
            label: title,
            color: const Color(0xFF4A90E2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Row(children: [
                const Icon(Icons.event, size: 18, color: Colors.black54), 
                const SizedBox(width: 4), 
                Expanded(child: Text(date, overflow: TextOverflow.ellipsis)), 
                const SizedBox(width: 16), 
                const Icon(Icons.payments_outlined, size: 18, color: Colors.black54), 
                const SizedBox(width: 4), 
                Text('₱ $budget')
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpen, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.teal, 
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ), 
                    child: const Text('Open')
                  )
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloaded: $title'),
                          backgroundColor: AppTheme.teal,
                          action: SnackBarAction(
                            label: 'View',
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.file_download_outlined, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.delete_outline, size: 20),
                  ),
                ),
              ]),
            ),
          ]),
        )
      ]),
    );
  }
}
