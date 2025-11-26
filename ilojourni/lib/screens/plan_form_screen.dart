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
  String? _selectedBudget;
  int? _selectedDays;
  final Set<String> _styles = {};

  final List<String> _budgetOptions = [
    '₱1,000 - ₱3,000',
    '₱3,000 - ₱5,000',
    '₱5,000 - ₱10,000',
    '₱10,000+',
  ];

  final List<int> _daysOptions = [1, 2, 3, 4, 5, 6, 7];

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
              const SizedBox(height: 24),
              Text('Budget', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _selectedBudget,
                  hint: const Text('Select budget range'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _budgetOptions.map((budget) {
                    return DropdownMenuItem<String>(
                      value: budget,
                      child: Text(budget),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBudget = value),
                ),
              ),
              const SizedBox(height: 20),
              Text('Number of Days', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<int>(
                  value: _selectedDays,
                  hint: const Text('Select number of days'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _daysOptions.map((days) {
                    return DropdownMenuItem<int>(
                      value: days,
                      child: Text('$days ${days == 1 ? "Day" : "Days"}'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedDays = value),
                ),
              ),
              const SizedBox(height: 20),
              Text('Travel Style', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StyleChip(
                    label: 'Culture',
                    icon: Icons.account_balance,
                    selected: _styles.contains('Culture'),
                    onTap: () => setState(() => _styles.contains('Culture') ? _styles.remove('Culture') : _styles.add('Culture')),
                  ),
                  _StyleChip(
                    label: 'Nature',
                    icon: Icons.park_outlined,
                    selected: _styles.contains('Nature'),
                    onTap: () => setState(() => _styles.contains('Nature') ? _styles.remove('Nature') : _styles.add('Nature')),
                  ),
                  _StyleChip(
                    label: 'Foodie',
                    icon: Icons.restaurant_outlined,
                    selected: _styles.contains('Foodie'),
                    onTap: () => setState(() => _styles.contains('Foodie') ? _styles.remove('Foodie') : _styles.add('Foodie')),
                  ),
                  _StyleChip(
                    label: 'Arts',
                    icon: Icons.brush_outlined,
                    selected: _styles.contains('Arts'),
                    onTap: () => setState(() => _styles.contains('Arts') ? _styles.remove('Arts') : _styles.add('Arts')),
                  ),
                  _StyleChip(
                    label: 'Adventure',
                    icon: Icons.terrain,
                    selected: _styles.contains('Adventure'),
                    onTap: () => setState(() => _styles.contains('Adventure') ? _styles.remove('Adventure') : _styles.add('Adventure')),
                  ),
                  _StyleChip(
                    label: 'Chill',
                    icon: Icons.coffee_outlined,
                    selected: _styles.contains('Chill'),
                    onTap: () => setState(() => _styles.contains('Chill') ? _styles.remove('Chill') : _styles.add('Chill')),
                  ),
                  _StyleChip(
                    label: 'Budget',
                    icon: Icons.savings_outlined,
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
                    if (_selectedBudget == null || _selectedDays == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select budget and number of days')),
                      );
                      return;
                    }
                    if (_styles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one travel style')),
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      ItineraryScreen.route,
                      arguments: {
                        'budget': _selectedBudget,
                        'days': _selectedDays,
                        'styles': _styles.toList(),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Plan My Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
