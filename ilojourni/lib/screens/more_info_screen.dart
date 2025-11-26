import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LocationData {
  final String title;
  final String image;
  final List<String> tags;
  final String description;
  final String hours;
  final String location;
  final String price;
  final String bestTime;
  final String accessibility;
  final String activities;
  final List<NearbySpot> nearbySpots;

  const LocationData({
    required this.title,
    required this.image,
    required this.tags,
    required this.description,
    required this.hours,
    required this.location,
    required this.price,
    required this.bestTime,
    required this.accessibility,
    required this.activities,
    required this.nearbySpots,
  });

  static final locations = {
    'molo-church': LocationData(
      title: 'Molo Church Heritage Tour',
      image: 'assets/images/moloChurch.jpg',
      tags: ['Culture', 'Arts'],
      description: "Discover the charm of Molo Church, Iloilo's Gothic Revival treasure dedicated to St. Anne. Known as the 'Feminist Church' for its all-female saints, it's a must-see for history lovers and photographers alike.",
      hours: 'Daily, 6:00 AM - 8:00 PM',
      location: 'Jaro, Iloilo City',
      price: 'Free',
      bestTime: 'Late afternoon or sunset',
      accessibility: 'Wheelchair-friendly',
      activities: 'Sightseeing, photography, cultural tour',
      nearbySpots: [
        NearbySpot(id: 'molo-mansion', title: 'Molo Mansion', subtitle: 'Heritage house • 50m walk'),
        NearbySpot(id: 'cafe-panay', title: 'Cafe Panay', subtitle: 'Local favorite • 3-min walk'),
      ],
    ),
    'jaro-cathedral': LocationData(
      title: 'Jaro Cathedral',
      image: 'assets/images/jaroCathedral.jpg',
      tags: ['Culture', 'History', 'Architecture'],
      description: "The Metropolitan Cathedral of St. Elizabeth of Hungary, commonly known as Jaro Cathedral, is a stunning example of baroque architecture. Built in 1874, it features a majestic bell tower and houses the miraculous image of Our Lady of Candles, making it a pilgrimage site for devotees across the Philippines.",
      hours: 'Daily, 5:00 AM - 7:00 PM',
      location: 'Jaro, Iloilo City',
      price: 'Free',
      bestTime: 'Early morning or late afternoon',
      accessibility: 'Wheelchair-accessible ground floor',
      activities: 'Prayer, sightseeing, photography, religious tours',
      nearbySpots: [
        NearbySpot(id: 'jaro-plaza', title: 'Jaro Plaza', subtitle: 'Public park • Adjacent'),
        NearbySpot(id: 'camiña-balay', title: 'Camiña Balay nga Bato', subtitle: 'Heritage house museum • 10-min walk'),
      ],
    ),
    'esplanade': LocationData(
      title: 'Iloilo Esplanade',
      image: 'assets/images/esplanadeWalk.jpg',
      tags: ['Leisure', 'Scenic', 'Fitness'],
      description: "The Iloilo River Esplanade is a scenic 9.28-kilometer linear park along the Iloilo River. Perfect for jogging, cycling, or leisurely walks, the esplanade offers stunning sunset views, floating restaurants, and public art installations. It's a favorite spot for locals and tourists seeking relaxation and outdoor activities.",
      hours: 'Open 24 hours',
      location: 'Along Iloilo River, Iloilo City',
      price: 'Free',
      bestTime: 'Sunset (5:00 PM - 6:30 PM)',
      accessibility: 'Fully wheelchair and bike-friendly',
      activities: 'Jogging, cycling, sunset viewing, dining, photography',
      nearbySpots: [
        NearbySpot(id: 'river-wharf', title: 'River Wharf Seafood Restaurant', subtitle: 'Floating restaurant • On-site'),
        NearbySpot(id: 'sm-city', title: 'SM City Iloilo', subtitle: 'Shopping mall • 2km away'),
      ],
    ),
    'molo-mansion': LocationData(
      title: 'Molo Mansion',
      image: 'assets/images/moloMansion.jpg',
      tags: ['Heritage', 'History', 'Architecture'],
      description: "Molo Mansion, also known as Yusay-Consing Mansion, is a beautifully preserved ancestral house showcasing early 20th-century Filipino-Spanish colonial architecture. With its grand wooden interiors, antique furniture, and rich family history, the mansion offers a glimpse into the opulent lifestyle of Iloilo's elite during the Spanish and American periods.",
      hours: 'Tuesday to Sunday, 9:00 AM - 5:00 PM',
      location: 'Molo District, Iloilo City',
      price: '₱100 entrance fee',
      bestTime: 'Morning tours (9:00 AM - 11:00 AM)',
      accessibility: 'Limited wheelchair access (stairs present)',
      activities: 'Guided heritage tours, photography, historical exploration',
      nearbySpots: [
        NearbySpot(id: 'molo-church', title: 'Molo Church', subtitle: 'Gothic church • 50m walk'),
        NearbySpot(id: 'molo-plaza', title: 'Molo Plaza', subtitle: 'Public park • 5-min walk'),
      ],
    ),
    'netongs-batchoy': LocationData(
      title: "Netong's Original Special La Paz Batchoy",
      image: 'assets/images/netongsBatchoy.jpg',
      tags: ['Food', 'Local Cuisine', 'Must-Try'],
      description: "Netong's serves the original and authentic La Paz Batchoy, Iloilo's signature noodle soup made with pork organs, crushed pork cracklings, chicken stock, beef loin, and round noodles. Established decades ago, Netong's has become a pilgrimage site for food lovers seeking the true taste of this iconic Ilonggo dish in its birthplace.",
      hours: 'Daily, 8:00 AM - 8:00 PM',
      location: 'La Paz Public Market, Iloilo City',
      price: '₱60 - ₱120 per bowl',
      bestTime: 'Lunch or early dinner',
      accessibility: 'Ground floor, limited wheelchair space',
      activities: 'Dining, food photography, culinary exploration',
      nearbySpots: [
        NearbySpot(id: 'lapaz-market', title: 'La Paz Public Market', subtitle: 'Local market • Adjacent'),
        NearbySpot(id: 'deco-batchoy', title: "Deco's Original La Paz Batchoy", subtitle: 'Another batchoy spot • 100m walk'),
      ],
    ),
  };
}

class NearbySpot {
  final String id;
  final String title;
  final String subtitle;

  const NearbySpot({required this.id, required this.title, required this.subtitle});
}

class MoreInfoScreen extends StatelessWidget {
  const MoreInfoScreen({super.key});
  static const route = '/more-info';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationId = ModalRoute.of(context)?.settings.arguments as String? ?? 'molo-church';
    final location = LocationData.locations[locationId] ?? LocationData.locations['molo-church']!;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: Image.asset(
                    location.image,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 300,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE8B86D), Color(0xFFCD9A5B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          location.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBackground : Colors.white,
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: location.tags.map((tag) => _Chip(text: tag)).toList()),
                      const SizedBox(height: 12),
                      Text(
                        location.description,
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.access_time, text: location.hours),
                      _InfoRow(icon: Icons.place_outlined, text: location.location),
                      _InfoRow(icon: Icons.payments_outlined, text: location.price),
                      _InfoRow(icon: Icons.wb_sunny_outlined, text: location.bestTime),
                      _InfoRow(icon: Icons.accessible, text: location.accessibility),
                      _InfoRow(icon: Icons.local_activity_outlined, text: location.activities),
                      const SizedBox(height: 16),
                      const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          color: AppTheme.lightGrey,
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, size: 40, color: Colors.black26),
                              SizedBox(height: 8),
                              Text('Map View', style: TextStyle(color: Colors.black38)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Nearby Spots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...location.nearbySpots.map((spot) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            if (LocationData.locations.containsKey(spot.id)) {
                              Navigator.pushReplacementNamed(
                                context,
                                MoreInfoScreen.route,
                                arguments: spot.id,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening ${spot.title}...'),
                                  backgroundColor: AppTheme.teal,
                                ),
                              );
                            }
                          },
                          child: _NearbyItem(title: spot.title, subtitle: spot.subtitle),
                        ),
                      )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF4A4A4A) : Colors.black26),
        color: isDark ? AppTheme.darkCard : null,
      ),
      child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.black54),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
      ]),
    );
  }
}

class _NearbyItem extends StatelessWidget {
  const _NearbyItem({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : Colors.black12),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ]
          ),
        ),
        Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
      ]),
    );
  }
}
