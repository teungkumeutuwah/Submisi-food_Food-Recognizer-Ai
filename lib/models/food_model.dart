class FoodModel {
  final String name;
  final String scientificName;
  final String englishName;
  final double confidence;
  final int calories;
  final int carbs;
  final int fat;
  final int fiber;
  final int protein;
  final String healthAnalysis;
  final String halalStatus;
  final String halalReason;
  final String recipeTitle;
  final String recipeIngredients;
  final String recipeInstructions;
  final List<SuggestedRestaurant> suggestedRestaurants;

  FoodModel({
    required this.name,
    required this.scientificName,
    required this.englishName,
    required this.confidence,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.protein,
    required this.healthAnalysis,
    required this.halalStatus,
    required this.halalReason,
    required this.recipeTitle,
    required this.recipeIngredients,
    required this.recipeInstructions,
    required this.suggestedRestaurants,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    var restaurantsFromJson = json['suggestedRestaurants'] as List? ?? [];
    List<SuggestedRestaurant> restaurantList = restaurantsFromJson
        .map((r) => SuggestedRestaurant.fromJson(Map<String, dynamic>.from(r)))
        .toList();

    return FoodModel(
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      englishName: json['englishName'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      calories: json['calories'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      fiber: json['fiber'] ?? 0,
      protein: json['protein'] ?? 0,
      healthAnalysis: json['healthAnalysis'] ?? '',
      halalStatus: json['halalStatus'] ?? 'Halal',
      halalReason: json['halalReason'] ?? '',
      recipeTitle: json['recipeTitle'] ?? '',
      recipeIngredients: json['recipeIngredients'] ?? '',
      recipeInstructions: json['recipeInstructions'] ?? '',
      suggestedRestaurants: restaurantList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scientificName': scientificName,
      'englishName': englishName,
      'confidence': confidence,
      'calories': calories,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'protein': protein,
      'healthAnalysis': healthAnalysis,
      'halalStatus': halalStatus,
      'halalReason': halalReason,
      'recipeTitle': recipeTitle,
      'recipeIngredients': recipeIngredients,
      'recipeInstructions': recipeInstructions,
      'suggestedRestaurants': suggestedRestaurants.map((r) => r.toJson()).toList(),
    };
  }
}

class SuggestedRestaurant {
  final String name;
  final String address;
  final double rating;

  SuggestedRestaurant({
    required this.name,
    required this.address,
    required this.rating,
  });

  factory SuggestedRestaurant.fromJson(Map<String, dynamic> json) {
    return SuggestedRestaurant(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'rating': rating,
    };
  }
}
