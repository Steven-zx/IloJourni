import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import '../services/connectivity_service.dart';
import 'itinerary_screen.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key});
  static const route = '/plan';

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final Set<String> _styles = {};
  bool _isGenerating = false;

  @override
  void dispose() {
    _budgetController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(leading: BackButton(color: isDark ? Colors.white : Colors.black87)),
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
                    Text("Set your budget, pick your style, and we'll do the rest.", textAlign: TextAlign.center, style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: isDark ? Colors.white60 : Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Budget', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter your budget (₱)',
                  prefixText: '₱ ',
                  filled: true,
                  fillColor: isDark ? AppTheme.darkBackground : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppTheme.darkTeal : AppTheme.teal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              Text('Number of Days', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter number of days',
                  suffixText: 'days',
                  filled: true,
                  fillColor: isDark ? AppTheme.darkBackground : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppTheme.darkTeal : AppTheme.teal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  onPressed: _isGenerating ? null : _generateItinerary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Plan My Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateItinerary() async {
    // Check internet connectivity first
    if (ConnectivityService.instance.isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('No internet connection. AI generation requires internet.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final budget = _budgetController.text.trim();
    final daysText = _daysController.text.trim();
    
    if (budget.isEmpty || daysText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter budget and number of days')),
      );
      return;
    }
    
    final days = int.tryParse(daysText);
    if (days == null || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of days')),
      );
      return;
    }

    if (days > 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 7 days per trip')),
      );
      return;
    }
    
    if (_styles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one travel style')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final geminiService = await GeminiService.getInstance();
      
      // Show loading dialog with progress
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Creating your perfect itinerary...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take 5-10 seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );

      final itinerary = await geminiService.generateItinerary(
        budget: int.parse(budget),
        days: days,
        travelStyles: _styles.toList(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      Navigator.pushNamed(
        context,
        ItineraryScreen.route,
        arguments: {
          'itinerary': itinerary,
          'budget': '₱$budget',
          'days': days,
          'styles': _styles.toList(),
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      String errorMessage = 'Failed to generate itinerary';
      
      if (e.toString().contains('API key')) {
        errorMessage = 'Invalid API key. Please check your configuration.';
      } else if (e.toString().contains('quota')) {
        errorMessage = 'API quota exceeded. Please try again later.';
      } else if (e.toString().contains('parse')) {
        errorMessage = 'Received invalid response. Please try again.';
      } else if (e.toString().contains('Empty response')) {
        errorMessage = 'No response from AI. Please check your internet connection.';
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Generation Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage),
              const SizedBox(height: 8),
              Text(
                'Technical details: ${e.toString()}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? (isDark ? AppTheme.darkTeal : AppTheme.teal) : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? (isDark ? AppTheme.darkTeal : AppTheme.teal) : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
