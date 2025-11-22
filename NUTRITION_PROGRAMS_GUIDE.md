# Nutrition Programs Feature Guide

## Overview
The app now supports **two types of programs**:
1. **Regular Programs** - Time-based programs with schedules (Yoga, Pilates, Therapy, etc.)
2. **Nutrition Programs** - Meal-based programs with flexible subscription options

## For Center Admins

### Creating a Nutrition Program

When creating a program, admins can now select the program type:

#### Regular Program Fields:
- Title, Description, Photo
- Trainer/Instructor name
- Start Date & End Date
- Weekly Days (Sun, Mon, Tue, etc.)
- Start Time & Duration
- Price

#### Nutrition Program Fields:
- Title, Description, Photo
- Trainer/Nutritionist name
- **Meals Per Day** (e.g., 3 meals)
- **Days Per Week** (e.g., 5 days)
- **Subscription Months** (e.g., 3 months)
- **Base Price** (for the configuration above)

### Example Nutrition Program Setup:
```
Title: "Healthy Meal Plan"
Description: "Balanced nutrition delivered to your door"
Meals Per Day: 3
Days Per Week: 5
Subscription Duration: 3 months
Price: BHD 450
```

This means: 450 BHD for 3 meals/day, 5 days/week, for 3 months.

## For Customers

### Subscribing to Nutrition Programs

Customers can **customize their subscription** by selecting:
1. **Duration**: 1, 2, 3, 6, or 12 months
2. **Days Per Week**: 3, 5, or 7 days
3. **Meals Per Day**: 1, 2, or 3 meals

### Price Calculation

The price is calculated based on the **per-meal cost**:

**Example:**
- Admin sets: 3 meals/day × 5 days/week × 3 months = BHD 450
- Total meals: 3 × 5 × 4 weeks × 3 months = 180 meals
- Price per meal: 450 ÷ 180 = BHD 2.50/meal

**Customer selects: 2 meals/day × 7 days/week × 1 month**
- Total meals: 2 × 7 × 4 weeks × 1 month = 56 meals
- Final price: 56 × 2.50 = **BHD 140**

### Customer Selection UI

The customer will see:
```
┌─────────────────────────────────────┐
│ Select Your Plan                    │
├─────────────────────────────────────┤
│ Duration:                           │
│ ○ 1 Month  ○ 2 Months  ● 3 Months  │
│                                     │
│ Days Per Week:                      │
│ ○ 3 Days   ● 5 Days    ○ 7 Days    │
│                                     │
│ Meals Per Day:                      │
│ ○ 1 Meal   ○ 2 Meals   ● 3 Meals   │
│                                     │
│ Your Selection:                     │
│ 3 Months • 5 Days/Week • 3 Meals/Day│
│                                     │
│ Total Price: BHD 450.00             │
│ (180 meals @ BHD 2.50/meal)         │
└─────────────────────────────────────┘
```

## Database Structure

### ProgramModel Fields:

```dart
class ProgramModel {
  // Common fields
  final String id;
  final String title;
  final String description;
  final double price;
  final String trainer;
  final ProgramType programType; // regular or nutrition
  
  // Regular program fields
  final List<DayOfWeek> weeklyDays;
  final String startTime;
  final int durationMinutes;
  final DateTime? programStartDate;
  final DateTime? programEndDate;
  
  // Nutrition program fields
  final int? mealsPerDay;
  final int? daysPerWeek;
  final int? subscriptionMonths;
}
```

## Implementation Status

✅ **Completed:**
- ProgramModel updated with nutrition fields
- ProgramType enum (regular, nutrition)
- Price calculation method
- NutritionSubscriptionOption model

⏳ **Next Steps:**
1. Update center admin program creation UI to support both types
2. Create nutrition program detail screen for customers
3. Add nutrition subscription selection UI
4. Update subscription model to store nutrition preferences
5. Add nutrition program filtering in customer views

## Benefits

### For Centers:
- Offer flexible meal plans
- Attract nutrition-focused customers
- Automated pricing for different configurations
- Easy to manage meal delivery schedules

### For Customers:
- Choose plans that fit their needs
- Transparent pricing
- Flexible subscription options
- See exactly what they're paying for
