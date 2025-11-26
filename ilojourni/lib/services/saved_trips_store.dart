import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destination.dart';

class SavedTrip {
  SavedTrip({
    required this.title,
    required this.dateRange,
    required this.budget,
    required this.image,
    required this.itinerary,
    this.isOfflineAvailable = true,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();
  
  final String title;
  final String dateRange;
  final int budget;
  final String image;
  final GeneratedItinerary itinerary;
  final bool isOfflineAvailable;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'title': title,
    'dateRange': dateRange,
    'budget': budget,
    'image': image,
    'itinerary': itinerary.toJson(),
    'isOfflineAvailable': isOfflineAvailable,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedTrip.fromJson(Map<String, dynamic> json) => SavedTrip(
    title: json['title'] as String,
    dateRange: json['dateRange'] as String,
    budget: json['budget'] as int,
    image: json['image'] as String,
    itinerary: GeneratedItinerary.fromJson(json['itinerary'] as Map<String, dynamic>),
    isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? true,
    savedAt: json['savedAt'] != null 
        ? DateTime.parse(json['savedAt'] as String)
        : DateTime.now(),
  );
}

class SavedTripsStore extends ChangeNotifier {
  static final SavedTripsStore _instance = SavedTripsStore._();
  SavedTripsStore._();
  static SavedTripsStore get instance => _instance;

  final List<SavedTrip> _trips = [];
  List<SavedTrip> get trips => List.unmodifiable(_trips);
  bool _isInitialized = false;

  static const String _storageKey = 'saved_trips';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tripsJson = prefs.getString(_storageKey);
      
      if (tripsJson != null) {
        final List<dynamic> decoded = json.decode(tripsJson) as List;
        _trips.clear();
        _trips.addAll(decoded.map((item) => SavedTrip.fromJson(item as Map<String, dynamic>)));
        notifyListeners();
      }
      _isInitialized = true;
    } catch (e) {
      // print('Error loading saved trips: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tripsJson = json.encode(_trips.map((trip) => trip.toJson()).toList());
      await prefs.setString(_storageKey, tripsJson);
    } catch (e) {
      // print('Error saving trips: $e');
    }
  }

  static Future<void> add(SavedTrip trip) async {
    _instance._trips.add(trip);
    _instance.notifyListeners();
    await _instance._saveToStorage();
  }

  static Future<void> removeAt(int index) async {
    _instance._trips.removeAt(index);
    _instance.notifyListeners();
    await _instance._saveToStorage();
  }

  static Future<void> clear() async {
    _instance._trips.clear();
    _instance.notifyListeners();
    await _instance._saveToStorage();
  }
}
