import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'plan_form_screen.dart';
import 'more_info_screen.dart';
import 'manual_itinerary_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teal header section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Maayong Adlaw!',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search destinations...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey[400]),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCard : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 20),
                    // White card with title and buttons
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Your Iloilo Journey\nStarts Here',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3, color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tell us your budget and preferences, we\'ll\ncraft the perfect adventure',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          // Start Planning AI button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, PlanFormScreen.route),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 20),
                              label: const Text('Start Planning AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Build Manually button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, ManualItineraryScreen.route),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.teal, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.teal, size: 20),
                              label: const Text('Build Manually', style: TextStyle(color: AppTheme.teal, fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BannerCarousel(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Popular Destinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Icon(Icons.more_horiz, color: Colors.grey[400]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _TripCard(
                            title: 'Esplanade Walk',
                            image: 'assets/images/esplanadeWalk.jpg',
                            imageColor: const Color(0xFF4A90E2),
                            tags: const ['Leisure', 'Scenic'],
                            price: 'Free • Open 24hrs',
                            onTap: () => Navigator.pushNamed(context, MoreInfoScreen.route, arguments: 'esplanade'),
                          ),
                          const SizedBox(width: 12),
                          _TripCard(
                            title: 'Jaro Cathedral',
                            image: 'assets/images/jaroCathedral.jpg',
                            imageColor: const Color(0xFFE8B86D),
                            tags: const ['Culture', 'History'],
                            price: 'Free • Daily tours',
                            onTap: () => Navigator.pushNamed(context, MoreInfoScreen.route, arguments: 'jaro-cathedral'),
                          ),
                          const SizedBox(width: 12),
                          _TripCard(
                            title: 'Molo Church',
                            image: 'assets/images/moloChurch.jpg',
                            imageColor: const Color(0xFFCD9A5B),
                            tags: const ['Culture', 'Arts'],
                            price: 'Free • Gothic Revival',
                            onTap: () => Navigator.pushNamed(context, MoreInfoScreen.route, arguments: 'molo-church'),
                          ),
                          const SizedBox(width: 12),
                          _TripCard(
                            title: 'Netong\'s Batchoy',
                            image: 'assets/images/netongsBatchoy.jpg',
                            imageColor: const Color(0xFFD4A574),
                            tags: const ['Food', 'Must-Try'],
                            price: '₱60-120 per bowl',
                            onTap: () => Navigator.pushNamed(context, MoreInfoScreen.route, arguments: 'netongs-batchoy'),
                          ),
                          const SizedBox(width: 12),
                          _TripCard(
                            title: 'Molo Mansion',
                            image: 'assets/images/moloMansion.jpg',
                            imageColor: const Color(0xFFB8956A),
                            tags: const ['Heritage', 'History'],
                            price: '₱100 entrance',
                            onTap: () => Navigator.pushNamed(context, MoreInfoScreen.route, arguments: 'molo-mansion'),
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

class _BannerCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/dinagyangBanner.png',
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 140,
          width: double.infinity,
          color: const Color(0xFF4E0D0D),
          alignment: Alignment.center,
          child: const Text('Dinagyang Banner', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.title, required this.image, this.imageColor, required this.tags, required this.price, this.onTap});
  final String title;
  final String image;
  final Color? imageColor;
  final List<String> tags;
  final String price;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
      width: 160,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: image.isEmpty 
              ? Container(height: 120, width: 160, color: imageColor ?? AppTheme.lightGrey)
              : Image.asset(image, height: 120, width: 160, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 120, width: 160, color: imageColor ?? AppTheme.lightGrey)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Wrap(spacing: 3, runSpacing: 3, children: tags.map((t) => _chip(context, t)).toList()),
                const SizedBox(height: 4),
                Text(price, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    ));
  }

  static Widget _chip(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A3A3A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF4A4A4A) : Colors.grey[300]!),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black)),
      );
  }
}
