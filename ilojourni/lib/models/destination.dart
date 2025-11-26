class Destination {
  final String id;
  final String name;
  final String description;
  final String district;
  final String category;
  final double latitude;
  final double longitude;
  final String image;
  final int entranceFee;
  final String estimatedTime;
  final List<String> tags;
  final String openingHours;
  final bool isPopular;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.district,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.entranceFee,
    required this.estimatedTime,
    required this.tags,
    required this.openingHours,
    this.isPopular = false,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      district: json['district'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      image: json['image'] as String,
      entranceFee: json['entranceFee'] as int,
      estimatedTime: json['estimatedTime'] as String,
      tags: List<String>.from(json['tags'] as List),
      openingHours: json['openingHours'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'district': district,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
      'entranceFee': entranceFee,
      'estimatedTime': estimatedTime,
      'tags': tags,
      'openingHours': openingHours,
      'isPopular': isPopular,
    };
  }
}

class GeneratedItinerary {
  final String title;
  final int totalBudget;
  final int totalCost;
  final List<DayPlan> days;
  final String summary;

  GeneratedItinerary({
    required this.title,
    required this.totalBudget,
    required this.totalCost,
    required this.days,
    required this.summary,
  });

  factory GeneratedItinerary.fromJson(Map<String, dynamic> json) {
    return GeneratedItinerary(
      title: json['title'] as String,
      totalBudget: json['totalBudget'] as int,
      totalCost: json['totalCost'] as int,
      days: (json['days'] as List)
          .map((day) => DayPlan.fromJson(day as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'totalBudget': totalBudget,
      'totalCost': totalCost,
      'days': days.map((day) => day.toJson()).toList(),
      'summary': summary,
    };
  }
}

class DayPlan {
  final int dayNumber;
  final String theme;
  final List<Activity> activities;
  final int totalCost;

  DayPlan({
    required this.dayNumber,
    required this.theme,
    required this.activities,
    required this.totalCost,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      dayNumber: json['dayNumber'] as int,
      theme: json['theme'] as String,
      activities: (json['activities'] as List)
          .map((activity) => Activity.fromJson(activity as Map<String, dynamic>))
          .toList(),
      totalCost: json['totalCost'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'theme': theme,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'totalCost': totalCost,
    };
  }
}

class Activity {
  final String type; // 'destination', 'meal', 'transport'
  final String name;
  final String description;
  final String time;
  final int cost;
  final String? location;
  final List<String>? tags;
  final String? image;

  Activity({
    required this.type,
    required this.name,
    required this.description,
    required this.time,
    required this.cost,
    this.location,
    this.tags,
    this.image,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      cost: json['cost'] as int,
      location: json['location'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'time': time,
      'cost': cost,
      'location': location,
      'tags': tags,
      'image': image,
    };
  }
}
