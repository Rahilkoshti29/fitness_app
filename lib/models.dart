class WorkoutLog {
  final int? id;
  final String date;
  final String type;
  final int duration; // minutes
  final int calories;
  final int steps;
  final String notes;

  WorkoutLog({
    this.id,
    required this.date,
    required this.type,
    required this.duration,
    required this.calories,
    required this.steps,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'type': type,
    'duration': duration,
    'calories': calories,
    'steps': steps,
    'notes': notes,
  };

  factory WorkoutLog.fromMap(Map<String, dynamic> m) => WorkoutLog(
    id: m['id'],
    date: m['date'],
    type: m['type'],
    duration: m['duration'],
    calories: m['calories'],
    steps: m['steps'],
    notes: m['notes'] ?? '',
  );
}

class NutritionLog {
  final int? id;
  final String date;
  final String meal; // Breakfast, Lunch, Dinner, Snack
  final String food;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  NutritionLog({
    this.id,
    required this.date,
    required this.meal,
    required this.food,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'meal': meal,
    'food': food,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  factory NutritionLog.fromMap(Map<String, dynamic> m) => NutritionLog(
    id: m['id'],
    date: m['date'],
    meal: m['meal'],
    food: m['food'],
    calories: m['calories'],
    protein: (m['protein'] as num).toDouble(),
    carbs: (m['carbs'] as num).toDouble(),
    fat: (m['fat'] as num).toDouble(),
  );
}

class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;
  final int calorieGoal;
  final int stepGoal;

  UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    this.calorieGoal = 2000,
    this.stepGoal = 10000,
  });

  double get bmi {
    final h = height / 100;
    return weight / (h * h);
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'weight': weight,
    'height': height,
    'calorieGoal': calorieGoal,
    'stepGoal': stepGoal,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'] ?? 'Athlete',
    age: m['age'] ?? 25,
    weight: (m['weight'] as num?)?.toDouble() ?? 70.0,
    height: (m['height'] as num?)?.toDouble() ?? 175.0,
    calorieGoal: m['calorieGoal'] ?? 2000,
    stepGoal: m['stepGoal'] ?? 10000,
  );
}