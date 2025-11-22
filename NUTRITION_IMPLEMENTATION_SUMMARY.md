# Nutrition Programs Implementation Summary

## ✅ What's Been Implemented

### 1. **ProgramModel Updates** (`lib/models/program_model.dart`)

Added support for two program types:

```dart
enum ProgramType { regular, nutrition }
```

**New Fields:**
- `programType` - Distinguishes between regular and nutrition programs
- `mealsPerDay` - Number of meals per day (e.g., 3)
- `daysPerWeek` - Number of days per week (e.g., 5)
- `subscriptionMonths` - Base subscription duration (e.g., 3 months)

**New Methods:**
- `isNutritionProgram` - Check if program is nutrition type
- `nutritionDetails` - Get formatted nutrition details string
- `calculateNutritionPrice()` - Calculate price based on customer selection

### 2. **NutritionSubscriptionOption Model** (`lib/models/nutrition_subscription_option.dart`)

Represents customer's nutrition subscription choices:
- Duration (months)
- Days per week
- Meals per day
- Calculated price
- Helper methods for display

### 3. **Example UI Widget** (`lib/widgets/nutrition_program_form_example.dart`)

Complete example of nutrition program creation form with:
- Visual meal/day selector (1, 2, 3)
- Days/week selector (3, 5, 7)
- Month duration chips (1, 2, 3, 6, 12)
- Real-time price breakdown
- Per-meal cost calculation

## 📋 How It Works

### Admin Side - Creating Nutrition Programs

1. **Select Program Type**: Regular or Nutrition
2. **Fill Basic Info**: Title, description, photo, nutritionist name
3. **Set Base Configuration**:
   - Meals per day: 3
   - Days per week: 5
   - Duration: 3 months
   - Price: BHD 450

This means: "450 BHD for 3 meals/day, 5 days/week, for 3 months"

### Customer Side - Subscribing

1. **View Nutrition Program**
2. **Customize Subscription**:
   - Choose duration: 1-12 months
   - Choose days/week: 3, 5, or 7 days
   - Choose meals/day: 1, 2, or 3 meals
3. **See Calculated Price** based on per-meal cost
4. **Subscribe**

### Price Calculation Logic

```dart
// Admin sets base configuration
Base: 3 meals/day × 5 days/week × 3 months × 4 weeks = 180 meals
Price: BHD 450
Per-meal cost: 450 ÷ 180 = BHD 2.50/meal

// Customer selects custom configuration
Customer: 2 meals/day × 7 days/week × 1 month × 4 weeks = 56 meals
Final price: 56 × 2.50 = BHD 140
```

## 🔧 Integration Steps

### Step 1: Update Program Creation Dialog

In your existing program creation screen (`center_profile_screen.dart` or similar):

```dart
// Add program type selector at the top
ProgramType _selectedProgramType = ProgramType.regular;

// Show different form fields based on type
if (_selectedProgramType == ProgramType.regular) {
  // Show: weekly days, start time, duration, dates
} else {
  // Show: meals per day, days per week, subscription months
}
```

### Step 2: Create Nutrition Program Detail Screen

For customers to view and subscribe to nutrition programs:

```dart
class NutritionProgramDetailScreen extends StatefulWidget {
  final ProgramModel program;
  
  // Show:
  // - Program details
  // - Customization options (months, days, meals)
  // - Real-time price calculation
  // - Subscribe button
}
```

### Step 3: Update Subscription Model

Add nutrition-specific fields to `SubscriptionModel`:

```dart
class SubscriptionModel {
  // ... existing fields
  
  // For nutrition subscriptions
  final int? selectedMealsPerDay;
  final int? selectedDaysPerWeek;
  final int? selectedMonths;
}
```

### Step 4: Filter Programs by Type

In customer views, allow filtering:

```dart
// Show all programs
// Show only regular programs
// Show only nutrition programs
```

## 📱 UI Examples

### Admin - Create Nutrition Program

```
┌─────────────────────────────────────┐
│ Create Program                      │
├─────────────────────────────────────┤
│ Program Type:                       │
│ ○ Regular  ● Nutrition              │
│                                     │
│ Title: Healthy Meal Plan            │
│ Nutritionist: Dr. Sarah Ahmed       │
│                                     │
│ Meals Per Day:                      │
│ [1] [2] [3] ← Click to select      │
│                                     │
│ Days Per Week:                      │
│ [3] [5] [7]                         │
│                                     │
│ Base Duration:                      │
│ ○ 1M  ○ 2M  ● 3M  ○ 6M  ○ 12M     │
│                                     │
│ Base Price: BHD 450                 │
│                                     │
│ 💡 Price Breakdown:                 │
│ Total meals: 180 meals              │
│ Price per meal: BHD 2.50            │
│                                     │
│ [Create Program]                    │
└─────────────────────────────────────┘
```

### Customer - Subscribe to Nutrition

```
┌─────────────────────────────────────┐
│ Healthy Meal Plan                   │
│ by Dr. Sarah Ahmed                  │
├─────────────────────────────────────┤
│ Customize Your Plan:                │
│                                     │
│ Duration:                           │
│ ○ 1M  ○ 2M  ● 3M  ○ 6M  ○ 12M     │
│                                     │
│ Days Per Week:                      │
│ ○ 3 Days  ● 5 Days  ○ 7 Days       │
│                                     │
│ Meals Per Day:                      │
│ ○ 1 Meal  ○ 2 Meals  ● 3 Meals     │
│                                     │
│ ────────────────────────────────    │
│ Your Selection:                     │
│ 3 Months • 5 Days • 3 Meals         │
│                                     │
│ Total: BHD 450.00                   │
│ (180 meals @ BHD 2.50/meal)         │
│                                     │
│ [Subscribe Now]                     │
└─────────────────────────────────────┘
```

## 🗂️ Database Structure

### Firestore Collection: `programs`

```json
{
  "id": "prog_123",
  "centerId": "center_456",
  "title": "Healthy Meal Plan",
  "description": "Balanced nutrition...",
  "price": 450.0,
  "trainer": "Dr. Sarah Ahmed",
  "programType": "nutrition",
  
  // Nutrition-specific fields
  "mealsPerDay": 3,
  "daysPerWeek": 5,
  "subscriptionMonths": 3,
  
  // Regular program fields (null for nutrition)
  "weeklyDays": [],
  "startTime": "",
  "programStartDate": null,
  "programEndDate": null
}
```

### Firestore Collection: `subscriptions`

```json
{
  "id": "sub_789",
  "userId": "user_123",
  "programId": "prog_123",
  "packageId": null,
  
  // For nutrition subscriptions
  "selectedMealsPerDay": 2,
  "selectedDaysPerWeek": 7,
  "selectedMonths": 1,
  "calculatedPrice": 140.0,
  
  "status": "active",
  "startDate": "2024-01-01",
  "renewalDate": "2024-02-01"
}
```

## ✨ Benefits

### For Centers:
- ✅ Offer flexible meal plans
- ✅ Attract nutrition-focused customers
- ✅ Automated pricing calculations
- ✅ Easy meal delivery management
- ✅ Differentiate from competitors

### For Customers:
- ✅ Choose plans that fit their needs
- ✅ Transparent pricing (see per-meal cost)
- ✅ Flexible subscription options
- ✅ Scale up or down as needed
- ✅ Clear value proposition

## 🚀 Next Steps

1. **Integrate into existing program creation flow**
   - Add program type selector
   - Show/hide fields based on type
   - Update validation logic

2. **Create customer nutrition detail screen**
   - Show program details
   - Add customization selectors
   - Real-time price updates
   - Subscribe button

3. **Update subscription flow**
   - Store nutrition preferences
   - Calculate correct price
   - Handle renewals

4. **Add filtering and search**
   - Filter by program type
   - Show nutrition programs separately
   - Add "Nutrition" category

5. **Testing**
   - Test price calculations
   - Test various configurations
   - Test edge cases (1 meal, 7 days, etc.)

## 📚 Files Created/Modified

### Created:
- `lib/models/nutrition_subscription_option.dart`
- `lib/widgets/nutrition_program_form_example.dart`
- `NUTRITION_PROGRAMS_GUIDE.md`
- `NUTRITION_IMPLEMENTATION_SUMMARY.md`

### Modified:
- `lib/models/program_model.dart` - Added nutrition support

### To Modify (Next):
- `lib/screens/center_admin/center_profile_screen.dart` - Add nutrition form
- `lib/screens/customer/program_detail_screen.dart` - Add nutrition view
- `lib/models/subscription_model.dart` - Add nutrition fields

## 💡 Tips

1. **Start Simple**: Implement basic nutrition program creation first
2. **Test Calculations**: Verify price calculations with various inputs
3. **User Feedback**: Get feedback on meal/day options (maybe add 4, 5 meals?)
4. **Delivery Days**: Consider adding delivery day selection (which days of the week)
5. **Meal Types**: Future enhancement - breakfast, lunch, dinner selection
6. **Dietary Preferences**: Future enhancement - vegan, keto, etc.

## 🎯 Example Use Cases

### Use Case 1: Weight Loss Program
- 3 meals/day
- 7 days/week
- 3 months
- BHD 900

### Use Case 2: Busy Professional
- 2 meals/day (lunch + dinner)
- 5 days/week (weekdays only)
- 1 month
- BHD 200

### Use Case 3: Athlete Nutrition
- 5 meals/day
- 7 days/week
- 6 months
- BHD 2,100

---

**Ready to implement!** The foundation is in place. Follow the integration steps above to complete the feature.
