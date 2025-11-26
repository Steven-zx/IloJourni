import 'package:flutter/material.dart';
import '../services/favorites_store.dart';
import '../theme/app_theme.dart';
import 'more_info_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  static const String route = '/favorites';

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';
  String? _selectedTag;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getAllTags() {
    final allTags = <String>{};
    for (final fav in FavoritesStore.instance.favorites) {
      allTags.addAll(fav.tags);
    }
    return allTags.toList()..sort();
  }

  List<FavoriteDestination> _getFilteredFavorites() {
    var filtered = FavoritesStore.instance.favorites;

    if (_searchQuery.isNotEmpty) {
      filtered = FavoritesStore.instance.searchFavorites(_searchQuery);
    }

    if (_selectedTag != null) {
      filtered = filtered.where((fav) => fav.tags.contains(_selectedTag)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: FavoritesStore.instance,
            builder: (context, _) {
              final hasItems = FavoritesStore.instance.favorites.isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear all favorites?'),
                      content: const Text(
                        'This will remove all destinations from your favorites list.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await FavoritesStore.instance.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All favorites cleared'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: FavoritesStore.instance,
        builder: (context, _) {
          final favorites = _getFilteredFavorites();
          final allTags = _getAllTags();

          if (FavoritesStore.instance.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any destination\nto add it to your favorites',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppTheme.darkCard : Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppTheme.darkBackground : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Tag filter chips
              if (allTags.isNotEmpty)
                Container(
                  height: 50,
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: allTags.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return FilterChip(
                          label: const Text('All'),
                          selected: _selectedTag == null,
                          onSelected: (_) {
                            setState(() {
                              _selectedTag = null;
                            });
                          },
                        );
                      }
                      final tag = allTags[index - 1];
                      return FilterChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (_) {
                          setState(() {
                            _selectedTag = _selectedTag == tag ? null : tag;
                          });
                        },
                      );
                    },
                  ),
                ),

              // Favorites list
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: Text(
                          'No favorites match your search',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          return _FavoriteCard(
                            favorite: favorites[index],
                            isDark: isDark,
                            onRemove: () async {
                              await FavoritesStore.instance.removeFavorite(
                                favorites[index].id,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed from favorites'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.isDark,
    required this.onRemove,
  });

  final FavoriteDestination favorite;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // Check if this destination has full details
    final availableLocations = [
      'molo-church',
      'jaro-cathedral',
      'esplanade',
      'molo-mansion',
      'netongs-batchoy'
    ];
    final hasDetails = availableLocations.contains(favorite.id);

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
                arguments: favorite.id,
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
                      child: favorite.image.isEmpty
                          ? Container(
                              width: 120,
                              height: 120,
                              color: AppTheme.lightGrey,
                            )
                          : Image.asset(
                              favorite.image,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                color: AppTheme.lightGrey,
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
                              favorite.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
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
                                    favorite.location,
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
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: favorite.tags.map((tag) {
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
                // Remove button
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRemove,
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
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
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
