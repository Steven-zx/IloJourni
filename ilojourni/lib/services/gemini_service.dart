import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/destination.dart';
import '../data/destinations_database.dart';

class GeminiService {
  static GeminiService? _instance;
  late GenerativeModel _model;
  
  GeminiService._() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 16384,
      ),
    );
  }

  static Future<GeminiService> getInstance() async {
    if (_instance == null) {
      await dotenv.load(fileName: ".env");
      _instance = GeminiService._();
    }
    return _instance!;
  }

  Future<GeneratedItinerary> generateItinerary({
    required int budget,
    required int days,
    required List<String> travelStyles,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < maxRetries) {
      try {
        attempts++;
        // print('🤖 Attempt $attempts/$maxRetries: Sending request to Gemini AI...');
        
        final destinationsJson = DestinationsDatabase.allDestinations
            .map((d) => d.toJson())
            .toList();

        final prompt = _buildPrompt(
          budget: budget,
          days: days,
          travelStyles: travelStyles,
          destinations: destinationsJson,
        );

        final response = await _model.generateContent([Content.text(prompt)]);
        
        if (response.text == null || response.text!.isEmpty) {
          throw Exception('Empty response from Gemini AI');
        }

        // print('✅ Received response from Gemini AI (${response.text!.length} characters)');

        // Parse the JSON response
        final jsonResponse = _extractJson(response.text!);
        if (jsonResponse.isEmpty) {
          throw FormatException('No valid JSON found in response');
        }
        final itinerary = GeneratedItinerary.fromJson(jsonResponse);

        // Validate the itinerary
        if (itinerary.days.isEmpty) {
          throw Exception('Generated itinerary has no days');
        }

        // print('✅ Successfully generated itinerary with ${itinerary.days.length} days');
        return itinerary;
        
      } on FormatException catch (e) {
        lastError = Exception('Failed to parse AI response: ${e.message}');
        // print('❌ JSON parsing error on attempt $attempts: $e');
        if (attempts < maxRetries) {
          await Future.delayed(Duration(seconds: attempts * 2));
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        // print('❌ Error on attempt $attempts: $e');
        
        // Check for network errors
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('socketexception') || 
            errorStr.contains('no address associated') ||
            errorStr.contains('network is unreachable') ||
            errorStr.contains('failed host lookup')) {
          throw Exception('NETWORK_ERROR: Unable to connect to AI service. Please check your internet connection.');
        }
        
        // Don't retry for certain errors
        if (e.toString().contains('API key') || e.toString().contains('quota')) {
          throw Exception('API Error: $e');
        }
        
        if (attempts < maxRetries) {
          // print('⏳ Retrying in ${attempts * 2} seconds...');
          await Future.delayed(Duration(seconds: attempts * 2));
        }
      }
    }

    throw lastError ?? Exception('Failed to generate itinerary after $maxRetries attempts');
  }

  String _buildPrompt({
    required int budget,
    required int days,
    required List<String> travelStyles,
    required List<Map<String, dynamic>> destinations,
  }) {
    return '''
You are an expert local travel planner for Iloilo City, Philippines with deep knowledge of the area. Create a personalized, realistic, and delightful itinerary.

USER PREFERENCES:
- Budget: ₱$budget
- Duration: $days day${days > 1 ? 's' : ''}
- Travel Styles: ${travelStyles.join(', ')}

AVAILABLE DESTINATIONS (with actual data):
${json.encode(destinations)}

TRANSPORTATION COSTS:
- Jeepney: ₱12-15 per ride (most common)
- Taxi: ₱40 base + ₱13.50/km
- Grab: ₱50-200 depending on distance
- Ferry to Guimaras: ₱15-20 one-way
- Boat to Gigantes: ₱1500-2000 round trip (shareable)

MEAL BUDGETS:
- Street food/budget: ₱80-150
- Local restaurant: ₱200-350
- Nice restaurant: ₱400-600

CRITICAL PLANNING RULES:
1. **Use ONLY destinations from the provided JSON above** - copy exact names, images, and prices
2. **Realistic timing**: Start 8-9 AM, end by 7-8 PM. Each destination needs 1-2 hours + travel time
3. **Logical flow**: Group nearby destinations together, minimize backtracking
4. **Meals**: Include breakfast, lunch, dinner. Use actual restaurants from the destination list when possible
5. **Transportation**: Add transport activities between locations (10-45 mins typically)
6. **Budget smart**: Total cost should be 90-100% of budget. Don't go over!
7. **Activity mix**: Balance based on travel styles - if "Foodie" is selected, include more food stops
10. **Opening hours**: Respect the openingHours in destination data
11. **Pacing**: Keep it simple! For $days days = ${days * 4}-${days * 5} activities MAXIMUM
12. **Image paths**: Use the exact "image" field from destination JSON. For meals: use "assets/images/breakfast.jpg" for breakfast, "assets/images/dinner.jpg" for lunch/dinner, "assets/images/coffee.jpg" for snacks/coffee
13. **BE CONCISE**: Keep descriptions SHORT (1 sentence max) to avoid truncation

OUTPUT FORMAT (MUST BE VALID JSON):
{
  "title": "Creative, appealing trip name (e.g., 'Iloilo Heritage & Food Adventure')",
  "totalBudget": $budget,
  "totalCost": <sum of all activity costs>,
  "summary": "Brief 2-3 sentence description highlighting the experience",
  "days": [
    {
      "dayNumber": 1,
      "theme": "Day theme reflecting activities (e.g., 'Cultural Immersion', 'Coastal Escape')",
      "totalCost": <sum of this day's costs>,
      "activities": [
        {
          "type": "destination",
          "name": "<exact name from destinations JSON>",
          "description": "<engaging 1-2 sentence description>",
          "time": "9:00 AM - 10:30 AM",
          "cost": <entranceFee from JSON>,
          "location": "<district from JSON>",
          "tags": ["<tags from JSON>"],
          "image": "<exact image path from JSON>"
        },
        {
          "type": "transport",
          "name": "Jeepney to [next location]",
          "description": "Travel via jeepney",
          "time": "10:30 AM - 10:45 AM",
          "cost": 15,
          "location": "",
          "tags": [],
          "image": ""
        },
        {
          "type": "meal",
          "name": "Breakfast/Lunch/Dinner at <restaurant from JSON or generic>",
          "description": "<what to eat>",
          "time": "12:00 PM - 1:00 PM",
          "cost": <realistic meal cost>,
          "location": "<area>",
          "tags": ["Foodie"],
          "image": "assets/images/breakfast.jpg for breakfast, assets/images/dinner.jpg for lunch/dinner, assets/images/coffee.jpg for snacks"
        }
      ]
    }
  ]
}

EXAMPLE ACTIVITY ORDER FOR 1 DAY:
1. Breakfast (meal) - ₱150
2. Transport (jeepney) - ₱15
3. Morning attraction (destination) - ₱0-200
4. Transport - ₱15
5. Lunch (meal) - ₱250
6. Afternoon attraction (destination) - ₱0-200
7. Transport - ₱15
8. Evening activity or dinner - ₱300-500

REMEMBER:
- Return ONLY the JSON object, no markdown, no extra text
- Keep descriptions to 1 SHORT sentence each
- All costs must be realistic integers
- Times must be sequential and realistic
- Use actual destination data - don't make up places!
- COMPLETE ALL $days DAYS - don't stop mid-response
''';
  }

  Map<String, dynamic> _extractJson(String text) {
    // Remove markdown code blocks if present
    String cleanText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    // Find the first { and last }
    final startIndex = cleanText.indexOf('{');
    int endIndex = cleanText.lastIndexOf('}');
    
    if (startIndex == -1) {
      // print('No opening brace found in response');
      throw FormatException('Invalid JSON response from AI - no opening brace');
    }
    
    if (endIndex == -1 || endIndex <= startIndex) {
      // print('No closing brace found, response likely truncated');
      throw FormatException('Invalid JSON response from AI - response truncated');
    }

    cleanText = cleanText.substring(startIndex, endIndex + 1);
    
    try {
      final parsed = json.decode(cleanText) as Map<String, dynamic>;
      
      // Validate required fields
      if (!parsed.containsKey('days') || (parsed['days'] as List).isEmpty) {
        throw FormatException('JSON missing days array');
      }
      
      return parsed;
    } catch (e) {
      // print('Failed to parse JSON: $cleanText');
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
