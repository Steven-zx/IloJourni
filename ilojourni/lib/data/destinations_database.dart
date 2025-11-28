import '../models/destination.dart';

class DestinationsDatabase {
  static final List<Destination> allDestinations = [
    // Culture & Heritage
    Destination(
      id: 'jaro-cathedral',
      name: 'Jaro Cathedral',
      description: 'Marian pilgrimage site with neo-Romanesque facade, belfry across the plaza, and the revered Our Lady of Candles.',
      district: 'Jaro',
      category: 'Culture',
      latitude: 10.7308,
      longitude: 122.5580,
      image: 'assets/images/jaroCathedral.jpg',
      entranceFee: 0,
      estimatedTime: '1-2 hours',
      tags: ['Culture', 'Arts', 'History', 'Photography'],
      openingHours: '6:00 AM - 7:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'molo-church',
      name: 'Molo Church',
      description: 'Gothic-Revival coral stone church famed for nave colonnades and all-female saint tableau—“The Feminist Church.”',
      district: 'Molo',
      category: 'Culture',
      latitude: 10.6977,
      longitude: 122.5443,
      image: 'assets/images/moloChurch.jpg',
      entranceFee: 0,
      estimatedTime: '1 hour',
      tags: ['Culture', 'Arts', 'History', 'Photography'],
      openingHours: '6:00 AM - 6:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'miagao-church',
      name: 'Miag-ao Church',
      description: 'UNESCO fortress church (1797) with tropical bas-relief of St. Christopher, papaya and coconut motifs on its facade.',
      district: 'Miag-ao',
      category: 'Culture',
      latitude: 10.6386,
      longitude: 122.2336,
      image: 'assets/images/miagaoChurch.jpg',
      entranceFee: 50,
      estimatedTime: '1-2 hours',
      tags: ['Culture', 'Arts', 'History', 'UNESCO'],
      openingHours: '8:00 AM - 5:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'museo-iloilo',
      name: 'Museo Iloilo',
      description: 'Provincial museum showcasing Iloilo\'s rich cultural heritage, artifacts, and history from prehistoric to modern times.',
      district: 'Iloilo City',
      category: 'Culture',
      latitude: 10.7202,
      longitude: 122.5621,
      image: 'assets/images/museoIloilo.jpg',
      entranceFee: 50,
      estimatedTime: '1-2 hours',
      tags: ['Culture', 'History', 'Arts', 'Education'],
      openingHours: '9:00 AM - 5:00 PM (Closed Mondays)',
      isPopular: false,
    ),
    Destination(
      id: 'molo-mansion',
      name: 'Molo Mansion',
      description: 'Restored 1920s heritage residence with artisan gift kiosks, landscaped grounds and a relaxed garden café.',
      district: 'Molo',
      category: 'Culture',
      latitude: 10.6985,
      longitude: 122.5452,
      image: 'assets/images/moloMansion.jpg',
      entranceFee: 100,
      estimatedTime: '1 hour',
      tags: ['Culture', 'History', 'Arts', 'Photography'],
      openingHours: '9:00 AM - 5:00 PM',
      isPopular: false,
    ),

    // Nature & Outdoors
    Destination(
      id: 'garin-farm',
      name: 'Garin Farm',
      description: 'Farm resort with 480-step white pilgrimage ascent, panoramic ridge views, produce stalls and family attractions.',
      district: 'San Joaquin',
      category: 'Nature',
      latitude: 10.5947,
      longitude: 122.0889,
      image: 'assets/images/garinFarm.jpg',
      entranceFee: 200,
      estimatedTime: '3-4 hours',
      tags: ['Nature', 'Adventure', 'Family', 'Photography'],
      openingHours: '7:00 AM - 5:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'isla-higantes',
      name: 'Isla de Gigantes',
      description: 'Island cluster of emerald waters, soaring limestone cliffs, sandbars and signature scallop feasts.',
      district: 'Carles',
      category: 'Nature',
      latitude: 11.4833,
      longitude: 123.4167,
      image: 'assets/images/islan higantes.png',
      entranceFee: 100,
      estimatedTime: 'Full day',
      tags: ['Nature', 'Beach', 'Adventure', 'Photography'],
      openingHours: 'Open 24/7',
      isPopular: true,
    ),
    Destination(
      id: 'guimaras-island',
      name: 'Guimaras Island',
      description: 'Mango capital offering island-hopping to quiet coves, orchard visits, marine sanctuaries and slow island life.',
      district: 'Guimaras',
      category: 'Nature',
      latitude: 10.5781,
      longitude: 122.6322,
      image: 'assets/images/guimarasIsland.jpg',
      entranceFee: 0,
      estimatedTime: 'Full day',
      tags: ['Nature', 'Beach', 'Chill', 'Foodie'],
      openingHours: 'Open 24/7',
      isPopular: true,
    ),

    // Food & Dining
    Destination(
      id: 'netongs-batchoy',
      name: 'Netong\'s Original La Paz Batchoy',
      description: 'Origin spot of La Paz Batchoy: rich bone broth, crushed chicharrón, pork innards, egg and fresh miki noodles.',
      district: 'La Paz',
      category: 'Food',
      latitude: 10.7309,
      longitude: 122.5689,
      image: 'assets/images/netongsBatchoy.jpg',
      entranceFee: 0,
      estimatedTime: '1 hour',
      tags: ['Foodie', 'Budget', 'Local'],
      openingHours: '7:00 AM - 7:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'robertos-siopao',
      name: 'Roberto\'s Siopao',
      description: 'Famous for their gigantic special queen siopao - a local favorite filled with delicious savory ingredients.',
      district: 'Iloilo City',
      category: 'Food',
      latitude: 10.6960,
      longitude: 122.5664,
      image: 'assets/images/robertos.jpg',
      entranceFee: 0,
      estimatedTime: '30 mins - 1 hour',
      tags: ['Foodie', 'Budget', 'Local'],
      openingHours: '7:00 AM - 9:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'breakthrough-restaurant',
      name: 'Breakthrough Restaurant',
      description: 'Open-air seaside dining; live seafood tanks, kinilaw, grilled diwal (angel wings) and sunset views.',
      district: 'Villa Beach',
      category: 'Food',
      latitude: 10.6653,
      longitude: 122.5089,
      image: 'assets/images/breakthrough.jpg',
      entranceFee: 0,
      estimatedTime: '1-2 hours',
      tags: ['Foodie', 'Chill', 'Nature'],
      openingHours: '10:00 AM - 10:00 PM',
      isPopular: true,
    ),
    Destination(
      id: 'madge-cafe',
      name: 'Madge Café',
      description: 'Iconic heritage café serving traditional Filipino merienda and specialties since 1959.',
      district: 'Iloilo City',
      category: 'Food',
      latitude: 10.6960,
      longitude: 122.5664,
      image: 'assets/images/madgeCafe.jpg',
      entranceFee: 0,
      estimatedTime: '1 hour',
      tags: ['Foodie', 'Culture', 'Chill'],
      openingHours: '6:30 AM - 7:30 PM',
      isPopular: false,
    ),

    // Urban & Modern
    Destination(
      id: 'esplanade-walk',
      name: 'Iloilo Esplanade',
      description: 'Rehabilitated riverside greenway for sunrise runs, sunset strolls, cycling and community fitness.',
      district: 'Iloilo City',
      category: 'Leisure',
      latitude: 10.6908,
      longitude: 122.5681,
      image: 'assets/images/esplanadeWalk.jpg',
      entranceFee: 0,
      estimatedTime: '1-2 hours',
      tags: ['Chill', 'Nature', 'Budget'],
      openingHours: 'Open 24/7',
      isPopular: true,
    ),
    Destination(
      id: 'smallville-complex',
      name: 'Smallville Complex',
      description: 'Entertainment district with restaurants, bars, cafés, and nightlife. The heart of Iloilo\'s food scene.',
      district: 'Mandurriao',
      category: 'Leisure',
      latitude: 10.7183,
      longitude: 122.5522,
      image: 'assets/images/smallville.jpg',
      entranceFee: 0,
      estimatedTime: '2-3 hours',
      tags: ['Foodie', 'Chill', 'Arts'],
      openingHours: '10:00 AM - 2:00 AM',
      isPopular: true,
    ),

    // Markets & Shopping
    Destination(
      id: 'central-market',
      name: 'Iloilo Central Market',
      description: 'Bustling public market where you can find fresh produce, local delicacies, and authentic Ilonggo products.',
      district: 'City Proper',
      category: 'Shopping',
      latitude: 10.6930,
      longitude: 122.5709,
      image: 'assets/images/centralMarket.jpg',
      entranceFee: 0,
      estimatedTime: '1-2 hours',
      tags: ['Budget', 'Foodie', 'Culture'],
      openingHours: '5:00 AM - 6:00 PM',
      isPopular: false,
    ),
  ];

  static List<Destination> getByCategory(String category) {
    return allDestinations.where((d) => d.category == category).toList();
  }

  static List<Destination> getByDistrict(String district) {
    return allDestinations.where((d) => d.district == district).toList();
  }

  static List<Destination> getByTags(List<String> tags) {
    return allDestinations.where((d) {
      return tags.any((tag) => d.tags.contains(tag));
    }).toList();
  }

  static List<Destination> getPopular() {
    return allDestinations.where((d) => d.isPopular).toList();
  }

  static List<Destination> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return allDestinations.where((d) {
      return d.name.toLowerCase().contains(lowerQuery) ||
          d.description.toLowerCase().contains(lowerQuery) ||
          d.district.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Destination? getById(String id) {
    try {
      return allDestinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}
