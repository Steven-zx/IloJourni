import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/placeholder_image.dart';

class BudgetTrackerScreen extends StatefulWidget {
  const BudgetTrackerScreen({super.key});
  static const route = '/budget';

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  final int _planned = 3000;
  int _spent = 0;

  void _addExpensePrompt() async {
    final controller = TextEditingController();
    final amount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white.withOpacity(0.98),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Other Expenses', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Amount'),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final v = int.tryParse(controller.text.trim());
                        if (v != null && v > 0) Navigator.pop(ctx, v);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal, shape: const StadiumBorder()),
                      child: const Text('Add'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
    if (amount != null) setState(() => _spent += amount);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_planned - _spent).clamp(0, _planned);
    final progress = _planned == 0 ? 0.0 : _spent / _planned;
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryBudget(planned: _planned, spent: _spent, remaining: remaining, progress: progress),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addExpensePrompt,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal, shape: const StadiumBorder(), elevation: 4),
              child: const Text('Add Other Expenses'),
            ),
          ),
          const SizedBox(height: 12),
          _DayHeader(day: 'Day 1', subtitle: '2 activities planned'),
          const SizedBox(height: 8),
          _BudgetPlaceCard(title: 'Jaro Cathedral', image: 'assets/images/jaroCathedral.jpg', imageColor: const Color(0xFFE8B86D), excerpt: 'Start your day with a visit to Jaro Cathedral, one of Iloilo\'s most historic churches known for its grand architecture and the miraculous Our Lady of Candles.'),
          const SizedBox(height: 10),
          const _RideRow(line: 'Ride: Ungka', details: 'Jeep • E-Bus    2-3 hours    Fare: ₱ 15'),
          const SizedBox(height: 10),
          _BudgetPlaceCard(title: "Netong's", image: 'assets/images/netongsBatchoy.jpg', imageColor: const Color(0xFFE67E22), excerpt: 'Grab brunch at Netong\'s, the home of the original La Paz Batchoy — a comforting bowl of Ilonggo goodness.'),
          const SizedBox(height: 10),
          const _RideRow(line: 'Ride: Villa / Mohon / Molo', details: 'Jeep • E-Bus    15-20min    Fare: ₱ 15-20'),
          const SizedBox(height: 10),
          _BudgetPlaceCard(title: 'Molo Church', image: 'assets/images/moloChurch.jpg', imageColor: const Color(0xFFCD9A5B), excerpt: "Visit Iloilo's iconic Gothic Revival church, home to the miraculous Our Lady of Candles."),
          const SizedBox(height: 10),
          _BudgetPlaceCard(title: 'Molo Mansion', image: 'assets/images/moloMansion.jpg', imageColor: const Color(0xFF8B7355), excerpt: 'Right across the church, visit Molo Mansion for local souvenirs and a quick coffee stop at Café Panay.'),
          const SizedBox(height: 10),
          _BudgetPlaceCard(title: 'Esplanade Walk', image: 'assets/images/esplanadeWalk.jpg', imageColor: const Color(0xFF27AE60), excerpt: 'Enjoy a peaceful sunset stroll at the Iloilo River Esplanade — perfect for nature lovers and photo ops.'),
          const SizedBox(height: 10),
          _BudgetPlaceCard(title: 'Jardin Mediterranean Cuisine', image: '', imageColor: const Color(0xFF16A085), excerpt: 'End your trip with dinner at Jardin, offering a relaxing garden ambiance and Mediterranean-inspired dishes.'),
        ],
      ),
    );
  }
}

class _SummaryBudget extends StatelessWidget {
  const _SummaryBudget({required this.planned, required this.spent, required this.remaining, required this.progress});
  final int planned;
  final int spent;
  final int remaining;
  final double progress;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))]),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Remaining Budget', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('₱ $remaining', style: const TextStyle(color: AppTheme.teal, fontSize: 24)),
              const SizedBox(height: 4),
              Text('of ₱ $planned total', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Column(children: [const Text('₱ 0'), const Text('Spent', style: TextStyle(color: Colors.black54))])),
                Expanded(child: Column(children: [Text('₱ $planned'), const Text('Planned', style: TextStyle(color: Colors.black54))])),
              ])
            ]),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(value: progress, color: AppTheme.teal, backgroundColor: AppTheme.lightGrey, strokeWidth: 6),
              Center(child: Text('${(progress * 100).round()}%')),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.subtitle});
  final String day;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.teal.withOpacity(.3))),
      child: Row(children: [Text(day, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(width: 8), Text(subtitle, style: const TextStyle(color: Colors.black54))]),
    );
  }
}

class _BudgetPlaceCard extends StatelessWidget {
  const _BudgetPlaceCard({required this.title, required this.image, this.imageColor, required this.excerpt});
  final String title;
  final String image;
  final Color? imageColor;
  final String excerpt;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), 
          child: image.isEmpty
            ? PlaceholderImage(height: 130, width: double.infinity, label: title, color: imageColor)
            : Image.asset(image, height: 130, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 130, color: AppTheme.lightGrey)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle()).copyWith(color: Colors.black, letterSpacing: .3)),
            const SizedBox(height: 6),
            Text(excerpt, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 6),
            Row(children: const [Icon(Icons.schedule, size: 18, color: Colors.black54), SizedBox(width: 4), Text('1 hour'), SizedBox(width: 12), Icon(Icons.place_outlined, size: 18, color: Colors.black54), SizedBox(width: 4), Text('Jaro, Iloilo City'), SizedBox(width: 12), Icon(Icons.chat_bubble_outline, size: 18, color: Colors.black54), SizedBox(width: 4), Text('Free Entry')]),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black26)), child: const Text('Culture')),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black26)), child: const Text('Arts')),
            ]),
          ]),
        )
      ]),
    );
  }
}

class _RideRow extends StatelessWidget {
  const _RideRow({required this.line, required this.details});
  final String line;
  final String details;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(children: [const Icon(Icons.directions_car), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(line, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(details, style: const TextStyle(color: Colors.black54))]))]),
    );
  }
}
