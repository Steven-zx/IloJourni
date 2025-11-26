import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteDestination {
  FavoriteDestination({
    required this.id,
    required this.name,
    required this.image,
    required this.location,
    required this.tags,
    required this.savedAt,
  });

  final String id;
  final String name;
  final String image;
  final String location;
  final List<String> tags;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'location': location,
        'tags': tags,
        'savedAt': savedAt.toIso8601String(),
      };

  factory FavoriteDestination.fromJson(Map<String, dynamic> json) =>
      FavoriteDestination(
        id: json['id'] as String,
        name: json['name'] as String,
        image: json['image'] as String,
        location: json['location'] as String,
        tags: List<String>.from(json['tags'] as List),
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class FavoritesStore extends ChangeNotifier {
  static final FavoritesStore _instance = FavoritesStore._();
  FavoritesStore._();
  static FavoritesStore get instance => _instance;

  final List<FavoriteDestination> _favorites = [];
  List<FavoriteDestination> get favorites => List.unmodifiable(_favorites);
  bool _isInitialized = false;

  static const String _storageKey = 'favorite_destinations';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_storageKey);

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson) as List;
        _favorites.clear();
        _favorites.addAll(decoded.map((item) =>
            FavoriteDestination.fromJson(item as Map<String, dynamic>)));
        notifyListeners();
      }
      _isInitialized = true;
      print('✅ Loaded ${_favorites.length} favorite destinations');
    } catch (e) {
      print('❌ Error loading favorites: $e');
      _isInitialized = true;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          json.encode(_favorites.map((f) => f.toJson()).toList());
      await prefs.setString(_storageKey, favoritesJson);
    } catch (e) {
      print('❌ Error saving favorites: $e');
    }
  }

  bool isFavorite(String destinationId) {
    return _favorites.any((f) => f.id == destinationId);
  }

  Future<void> toggleFavorite(FavoriteDestination destination) async {
    final index = _favorites.indexWhere((f) => f.id == destination.id);

    if (index != -1) {
      // Remove from favorites
      _favorites.removeAt(index);
      print('💔 Removed ${destination.name} from favorites');
    } else {
      // Add to favorites
      _favorites.add(destination);
      print('❤️ Added ${destination.name} to favorites');
    }

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> addFavorite(FavoriteDestination destination) async {
    if (!isFavorite(destination.id)) {
      _favorites.add(destination);
      notifyListeners();
      await _saveToStorage();
      print('❤️ Added ${destination.name} to favorites');
    }
  }

  Future<void> removeFavorite(String destinationId) async {
    final initialLength = _favorites.length;
    _favorites.removeWhere((f) => f.id == destinationId);
    if (_favorites.length < initialLength) {
      notifyListeners();
      await _saveToStorage();
      print('💔 Removed favorite');
    }
  }

  Future<void> clear() async {
    _favorites.clear();
    notifyListeners();
    await _saveToStorage();
    print('🗑️ Cleared all favorites');
  }

  List<FavoriteDestination> getFavoritesByTag(String tag) {
    return _favorites
        .where((f) => f.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
        .toList();
  }

  List<FavoriteDestination> searchFavorites(String query) {
    final lowerQuery = query.toLowerCase();
    return _favorites
        .where((f) =>
            f.name.toLowerCase().contains(lowerQuery) ||
            f.location.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
