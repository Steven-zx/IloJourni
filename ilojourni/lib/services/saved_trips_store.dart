import 'package:flutter/foundation.dart';

class SavedTrip {
  SavedTrip({required this.title, required this.dateRange, required this.budget, required this.image});
  final String title;
  final String dateRange;
  final int budget;
  final String image;
}

class SavedTripsStore extends ChangeNotifier {
  static final SavedTripsStore _instance = SavedTripsStore._();
  SavedTripsStore._();
  static SavedTripsStore get instance => _instance;

  final List<SavedTrip> _trips = [];
  List<SavedTrip> get trips => List.unmodifiable(_trips);

  static void add(SavedTrip trip) {
    _instance._trips.add(trip);
    _instance.notifyListeners();
  }

  static void removeAt(int index) {
    _instance._trips.removeAt(index);
    _instance.notifyListeners();
  }
}
