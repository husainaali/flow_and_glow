/// Model to represent customer's nutrition subscription choices
class NutritionSubscriptionOption {
  final int months;
  final int daysPerWeek;
  final int mealsPerDay;
  final double calculatedPrice;

  NutritionSubscriptionOption({
    required this.months,
    required this.daysPerWeek,
    required this.mealsPerDay,
    required this.calculatedPrice,
  });

  String get durationText {
    return months == 1 ? '1 Month' : '$months Months';
  }

  String get mealsText {
    return '$mealsPerDay meal${mealsPerDay > 1 ? 's' : ''} per day';
  }

  String get daysText {
    return '$daysPerWeek day${daysPerWeek > 1 ? 's' : ''} per week';
  }

  String get summary {
    return '$durationText • $daysText • $mealsText';
  }

  int get totalMeals {
    return months * 4 * daysPerWeek * mealsPerDay; // 4 weeks per month
  }

  double get pricePerMeal {
    return calculatedPrice / totalMeals;
  }
}
