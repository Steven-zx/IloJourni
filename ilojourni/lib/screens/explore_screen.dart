import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/favorites_store.dart';
import 'more_info_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialQuery;
  const ExploreScreen({super.key, this.initialQuery});
  static const route = '/explore';

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Favorites', 'Popular', 'Adventure', 'Culture', 'Nature', 'Foodie'];

  final List<DestinationItem> _allDestinations = [
    DestinationItem(
      id: 'isla-higantes',
      title: 'Isla Higantes',
      image: 'assets/images/islaHigantes.jpg',
      imageColor: const Color(0xFF4A90E2),
      description: 'End your trip with dinner at Jardin, offering a relaxing garden ambiance and Mediterranean-inspired dishes.',
      tags: ['Nature', 'Foodie'],
      location: 'Molo, Iloilo City',
      price: '₱100-500',
    ),
    DestinationItem(
      id: 'jaro-cathedral',
      title: 'Jaro Cathedral',
      image: 'assets/images/jaroCathedral.jpg',
      imageColor: const Color(0xFFE8B86D),
      description: 'Start your day with a visit to Jaro Cathedral, one of Iloilo\'s most historic churches known for its grand architecture and the miraculous Our Lady of Candles.',
      tags: ['Culture', 'Arts'],
      location: 'Jaro, Iloilo City',
      price: 'Free entry • Best at sunset',
    ),
    DestinationItem(
      id: 'esplanade',
      title: 'Esplanade Walk',
      image: 'assets/images/esplanadeWalk.jpg',
      imageColor: const Color(0xFF27AE60),
      description: 'Enjoy a peaceful sunset stroll at the Iloilo River Esplanade — perfect for nature lovers and photo ops.',
      tags: ['Nature', 'Foodie'],
      location: 'Molo, Iloilo City',
      price: 'Free • Open 24hrs',
    ),
    DestinationItem(
      id: 'molo-church',
      title: 'Molo Church',
      image: 'assets/images/moloChurch.jpg',
      imageColor: const Color(0xFFCD9A5B),
      description: "Visit Iloilo's iconic Gothic Revival church, home to the miraculous Our Lady of Candles.",
      tags: ['Culture', 'Arts'],
      location: 'Molo, Iloilo City',
      price: 'Free • Gothic Revival',
    ),
    DestinationItem(
      id: 'netongs-batchoy',
      title: 'Netong\'s Batchoy',
      image: 'assets/images/netongsBatchoy.jpg',
      imageColor: const Color(0xFFD4A574),
      description: 'Grab brunch at Netong\'s, the home of the original La Paz Batchoy — a comforting bowl of Ilonggo goodness.',
      tags: ['Food', 'Must-Try'],
      location: 'La Paz, Iloilo City',
      price: '₱60-120 per bowl',
    ),
    DestinationItem(
      id: 'molo-mansion',
      title: 'Molo Mansion',
      image: 'assets/images/moloMansion.jpg',
      imageColor: const Color(0xFFB8956A),
      description: 'Right across the church, visit Molo Mansion for local souvenirs and a quick coffee stop at Café Panay.',
      tags: ['Heritage', 'History'],
      location: 'Molo, Iloilo City',
      price: '₱100 entrance',
    ),
    DestinationItem(
      id: 'guimaras-island',
      title: 'Guimaras Island',
      image: 'assets/images/guimaras.jpg',
      imageColor: const Color(0xFF2ECC71),
      description: 'Take a day trip to Guimaras Island, famous for its sweet mangoes, pristine beaches, and laid-back island vibes.',
      tags: ['Nature', 'Adventure'],
      location: 'Guimaras',
      price: '₱15-30 boat ride',
    ),
    DestinationItem(
      id: 'breakthrough-restaurant',
      title: 'Breakthrough Restaurant',
      image: 'assets/images/breakthrough.jpg',
      imageColor: const Color(0xFF3498DB),
      description: 'Famous for fresh seafood by the sea, enjoy the catch of the day while watching the sunset over the water.',
      tags: ['Foodie', 'Scenic'],
      location: 'Villa, Iloilo City',
      price: '₱200-500 per meal',
    ),
    DestinationItem(
      id: 'mieg-ao-church',
      title: 'Miag-ao Church',
      image: 'assets/images/miagao.jpg',
      imageColor: const Color(0xFFE67E22),
      description: 'A UNESCO World Heritage Site, this fortress church is a masterpiece of Spanish colonial architecture.',
      tags: ['Culture', 'History'],
      location: 'Miag-ao, Iloilo',
      price: 'Free • 1.5 hours from city',
    ),
    DestinationItem(
      id: 'garin-farm',
      title: 'Garin Farm',
      image: 'assets/images/garin.jpg',
      imageColor: const Color(0xFF27AE60),
      description: 'Climb the pilgrimage site with 480 steps, enjoy the panoramic view, and visit the mini zoo and restaurant.',
      tags: ['Nature', 'Adventure'],
      location: 'San Joaquin, Iloilo',
      price: '₱150 entrance • 1.5 hours from city',
    ),
  ];

  List<DestinationItem> get _filteredDestinations {
    var results = _allDestinations;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      results = results.where((dest) {
        return dest.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               dest.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               dest.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'Favorites') {
        final favoriteIds = FavoritesStore.instance.favorites.map((f) => f.id).toSet();
        results = results.where((dest) => favoriteIds.contains(dest.id)).toList();
      } else if (_selectedCategory == 'Popular') {
        results = results.take(5).toList();
      } else {
        results = results.where((dest) {
          return dest.tags.any((tag) => tag.toLowerCase().contains(_selectedCategory.toLowerCase()));
        }).toList();
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredDests = _filteredDestinations;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkTeal : AppTheme.teal,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search destinations...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white54 : Colors.grey[400],
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
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
            // Category filters
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                    },
                    backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                    selectedColor: isDark ? AppTheme.darkTeal : AppTheme.teal,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? Colors.white24 : Colors.grey[300]!),
                    ),
                  );
                },
              ),
            ),
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'All'
                        ? 'Popular Destinations'
                        : _selectedCategory,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (filteredDests.length > 3)
                    Icon(
                      Icons.more_horiz,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                ],
              ),
            ),
            // Destinations list
            Expanded(
              child: filteredDests.isEmpty
                  ? Center(
                      child: Text(
                        'No destinations found',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredDests.length,
                      itemBuilder: (context, index) {
                        return _DestinationCard(
                          destination: filteredDests[index],
                          isDark: isDark,
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

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.destination,
    required this.isDark,
  });

  final DestinationItem destination;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Check if this destination has full details in MoreInfoScreen
    final availableLocations = [
      'molo-church',
      'jaro-cathedral',
      'esplanade',
      'molo-mansion',
      'netongs-batchoy'
    ];
    final hasDetails = availableLocations.contains(destination.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (hasDetails) {
              Navigator.pushNamed(
                context,
                MoreInfoScreen.route,
                arguments: destination.id,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('More details coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
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
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                      child: destination.image.isEmpty
                          ? Container(
                              width: 120,
                              height: 120,
                              color: destination.imageColor ?? AppTheme.lightGrey,
                            )
                          : Image.asset(
                              destination.image,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                color: destination.imageColor ?? AppTheme.lightGrey,
                              ),
                            ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              destination.description,
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: isDark ? Colors.white38 : Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    destination.location,
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: destination.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF3A3A3A)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF4A4A4A)
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isDark ? Colors.white70 : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Favorite button
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedBuilder(
                    animation: FavoritesStore.instance,
                    builder: (context, _) {
                      final isFavorite = FavoritesStore.instance.isFavorite(destination.id);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await FavoritesStore.instance.toggleFavorite(
                              FavoriteDestination(
                                id: destination.id,
                                name: destination.title,
                                image: destination.image,
                                location: destination.location,
                                tags: destination.tags,
                                savedAt: DateTime.now(),
                              ),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Removed from favorites'
                                        : 'Added to favorites',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : (isDark ? Colors.white70 : Colors.grey[600]),
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationItem {
  final String id;
  final String title;
  final String image;
  final Color? imageColor;
  final String description;
  final List<String> tags;
  final String location;
  final String price;

  DestinationItem({
    required this.id,
    required this.title,
    required this.image,
    this.imageColor,
    required this.description,
    required this.tags,
    required this.location,
    required this.price,
  });
}
