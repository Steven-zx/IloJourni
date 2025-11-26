import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'itinerary_screen.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key});
  static const route = '/plan';

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _budgetCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final Set<String> _styles = {};

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(int days) {
    if (days < 7) return '$days ${days == 1 ? "Day" : "Days"}';
    
    final months = days ~/ 30;
    final weeks = (days % 30) ~/ 7;
    final remainingDays = days % 7;
    
    final parts = <String>[];
    if (months > 0) parts.add('$months ${months == 1 ? "Month" : "Months"}');
    if (weeks > 0) parts.add('$weeks ${weeks == 1 ? "Week" : "Weeks"}');
    if (remainingDays > 0) parts.add('$remainingDays ${remainingDays == 1 ? "Day" : "Days"}');
    
    return parts.join(' and ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(color: Colors.black87)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('Your Iloilo Adventure\nAwaits', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text("Set your budget, pick your style, and we'll do the rest.", textAlign: TextAlign.center, style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Budget', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  prefixText: '₱ ',
                  hintText: 'Enter your budget',
                ),
              ),
              const SizedBox(height: 16),
              Text('Number of Days', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.event),
                  hintText: 'Enter number of days',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final days = int.tryParse(value);
                    if (days != null && days > 0) {
                      setState(() {});
                    }
                  }
                },
              ),
              if (_daysCtrl.text.isNotEmpty && int.tryParse(_daysCtrl.text) != null && int.parse(_daysCtrl.text) > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 6),
                  child: Text(
                    _formatDuration(int.parse(_daysCtrl.text)),
                    style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(color: AppTheme.teal, fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Travel Style', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StyleChip(
                    label: 'Culture',
                    icon: Icons.location_city,
                    selected: _styles.contains('Culture'),
                    onTap: () => setState(() => _styles.contains('Culture') ? _styles.remove('Culture') : _styles.add('Culture')),
                  ),
                  _StyleChip(
                    label: 'Nature',
                    icon: Icons.eco,
                    selected: _styles.contains('Nature'),
                    onTap: () => setState(() => _styles.contains('Nature') ? _styles.remove('Nature') : _styles.add('Nature')),
                  ),
                  _StyleChip(
                    label: 'Foodie',
                    icon: Icons.restaurant,
                    selected: _styles.contains('Foodie'),
                    onTap: () => setState(() => _styles.contains('Foodie') ? _styles.remove('Foodie') : _styles.add('Foodie')),
                  ),
                  _StyleChip(
                    label: 'Arts',
                    icon: Icons.palette,
                    selected: _styles.contains('Arts'),
                    onTap: () => setState(() => _styles.contains('Arts') ? _styles.remove('Arts') : _styles.add('Arts')),
                  ),
                  _StyleChip(
                    label: 'Adventure',
                    icon: Icons.hiking,
                    selected: _styles.contains('Adventure'),
                    onTap: () => setState(() => _styles.contains('Adventure') ? _styles.remove('Adventure') : _styles.add('Adventure')),
                  ),
                  _StyleChip(
                    label: 'Chill',
                    icon: Icons.local_cafe,
                    selected: _styles.contains('Chill'),
                    onTap: () => setState(() => _styles.contains('Chill') ? _styles.remove('Chill') : _styles.add('Chill')),
                  ),
                  _StyleChip(
                    label: 'Budget',
                    icon: Icons.savings,
                    selected: _styles.contains('Budget'),
                    onTap: () => setState(() => _styles.contains('Budget') ? _styles.remove('Budget') : _styles.add('Budget')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_budgetCtrl.text.isEmpty || _daysCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter budget and days')),
                      );
                      return;
                    }
                    final budget = int.tryParse(_budgetCtrl.text);
                    final days = int.tryParse(_daysCtrl.text);
                    if (budget == null || budget <= 0 || days == null || days <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid budget and days')),
                      );
                      return;
                    }
                    if (_styles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one travel style')),
                      );
                      return;
                    }
                    Navigator.pushNamed(context, ItineraryScreen.route);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal, shape: const StadiumBorder(), elevation: 4),
                  child: const Text('Plan My Journey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.teal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppTheme.teal : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
