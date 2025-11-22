# Nutrition Programs - Complete Flow Diagram

## 🎯 Overview

This document shows the complete flow from admin creating a nutrition program to customer subscribing.

---

## 📊 Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     CENTER ADMIN SIDE                            │
└─────────────────────────────────────────────────────────────────┘

1. CREATE NUTRITION PROGRAM
   ├─ Select: Program Type = "Nutrition"
   ├─ Enter: Title, Description, Photo
   ├─ Enter: Nutritionist Name
   ├─ Select: Meals Per Day (1, 2, or 3)
   ├─ Select: Days Per Week (3, 5, or 7)
   ├─ Select: Base Duration (1, 2, 3, 6, or 12 months)
   ├─ Enter: Base Price (e.g., BHD 450)
   └─ See: Automatic calculation
      ├─ Total meals = 3 × 5 × 3 × 4 = 180 meals
      └─ Per-meal price = 450 ÷ 180 = BHD 2.50/meal

2. SAVE TO DATABASE
   ├─ Firestore: /programs/{programId}
   └─ Fields:
      ├─ programType: "nutrition"
      ├─ mealsPerDay: 3
      ├─ daysPerWeek: 5
      ├─ subscriptionMonths: 3
      └─ price: 450.0

3. PROGRAM APPEARS IN APP
   ├─ Customer home screen
   ├─ Nutrition category
   └─ Center's program list

┌─────────────────────────────────────────────────────────────────┐
│                      CUSTOMER SIDE                               │
└─────────────────────────────────────────────────────────────────┘

4. BROWSE PROGRAMS
   ├─ See all programs
   ├─ Filter by "Nutrition"
   └─ Click on "Healthy Meal Plan"

5. VIEW PROGRAM DETAILS
   ├─ See: Title, Description, Photo
   ├─ See: Nutritionist name
   ├─ See: Base configuration (3 meals, 5 days, 3 months)
   └─ See: Base price (BHD 450)

6. CUSTOMIZE SUBSCRIPTION
   ├─ Select Duration:
   │  ├─ Options: 1, 2, 3, 6, 12 months
   │  └─ Customer picks: 1 month
   │
   ├─ Select Days Per Week:
   │  ├─ Options: 3, 5, 7 days
   │  └─ Customer picks: 7 days
   │
   └─ Select Meals Per Day:
      ├─ Options: 1, 2, 3 meals
      └─ Customer picks: 2 meals

7. SEE CALCULATED PRICE
   ├─ Calculation:
   │  ├─ Selected meals = 2 × 7 × 1 × 4 = 56 meals
   │  ├─ Per-meal price = BHD 2.50 (from admin's base)
   │  └─ Final price = 56 × 2.50 = BHD 140
   │
   └─ Display:
      ├─ "Your Selection:"
      ├─ "1 Month • 7 Days/Week • 2 Meals/Day"
      ├─ "Total: BHD 140.00"
      └─ "(56 meals @ BHD 2.50/meal)"

8. SUBSCRIBE
   ├─ Click "Subscribe Now"
   ├─ Select payment method
   └─ Confirm subscription

9. CREATE SUBSCRIPTION
   ├─ Firestore: /subscriptions/{subscriptionId}
   └─ Fields:
      ├─ userId: "user_123"
      ├─ programId: "prog_456"
      ├─ selectedMealsPerDay: 2
      ├─ selectedDaysPerWeek: 7
      ├─ selectedMonths: 1
      ├─ calculatedPrice: 140.0
      ├─ status: "active"
      ├─ startDate: "2024-01-01"
      └─ renewalDate: "2024-02-01"

10. CUSTOMER RECEIVES
    ├─ Confirmation notification
    ├─ Subscription appears in "My Subscriptions"
    └─ Meal delivery schedule

┌─────────────────────────────────────────────────────────────────┐
│                    ONGOING MANAGEMENT                            │
└─────────────────────────────────────────────────────────────────┘

11. CUSTOMER CAN:
    ├─ View upcoming meals
    ├─ Track delivery schedule
    ├─ Modify subscription (upgrade/downgrade)
    └─ Cancel or renew

12. CENTER CAN:
    ├─ View active nutrition subscriptions
    ├─ Manage meal deliveries
    ├─ Update program pricing
    └─ Track revenue
```

---

## 🔢 Price Calculation Examples

### Example 1: Exact Match
```
Admin Sets:
- 3 meals/day × 5 days/week × 3 months = BHD 450

Customer Selects:
- 3 meals/day × 5 days/week × 3 months

Calculation:
- Same as base → BHD 450 ✓
```

### Example 2: Less Meals
```
Admin Sets:
- 3 meals/day × 5 days/week × 3 months = BHD 450
- Per-meal: 450 ÷ 180 = BHD 2.50

Customer Selects:
- 2 meals/day × 5 days/week × 3 months

Calculation:
- Total meals: 2 × 5 × 12 = 120 meals
- Price: 120 × 2.50 = BHD 300 ✓
```

### Example 3: More Days
```
Admin Sets:
- 3 meals/day × 5 days/week × 3 months = BHD 450
- Per-meal: 450 ÷ 180 = BHD 2.50

Customer Selects:
- 3 meals/day × 7 days/week × 3 months

Calculation:
- Total meals: 3 × 7 × 12 = 252 meals
- Price: 252 × 2.50 = BHD 630 ✓
```

### Example 4: Shorter Duration
```
Admin Sets:
- 3 meals/day × 5 days/week × 3 months = BHD 450
- Per-meal: 450 ÷ 180 = BHD 2.50

Customer Selects:
- 3 meals/day × 5 days/week × 1 month

Calculation:
- Total meals: 3 × 5 × 4 = 60 meals
- Price: 60 × 2.50 = BHD 150 ✓
```

### Example 5: Custom Mix
```
Admin Sets:
- 3 meals/day × 5 days/week × 3 months = BHD 450
- Per-meal: 450 ÷ 180 = BHD 2.50

Customer Selects:
- 1 meal/day × 3 days/week × 6 months

Calculation:
- Total meals: 1 × 3 × 24 = 72 meals
- Price: 72 × 2.50 = BHD 180 ✓
```

---

## 🎨 UI Component Breakdown

### Admin Form Components
```
1. ProgramTypeSelector
   - Radio buttons: Regular / Nutrition

2. NutritionConfigSection (shown when type = nutrition)
   ├─ MealsPerDaySelector (1, 2, 3)
   ├─ DaysPerWeekSelector (3, 5, 7)
   ├─ DurationSelector (1, 2, 3, 6, 12 months)
   └─ PriceBreakdownCard
      ├─ Total meals calculation
      └─ Per-meal price

3. SaveButton
   - Validates all fields
   - Creates ProgramModel with programType = nutrition
```

### Customer View Components
```
1. ProgramDetailHeader
   ├─ Program photo
   ├─ Title
   ├─ Nutritionist name
   └─ Base configuration badge

2. SubscriptionCustomizer
   ├─ DurationPicker (1-12 months)
   ├─ DaysPerWeekPicker (3, 5, 7)
   └─ MealsPerDayPicker (1, 2, 3)

3. PriceCalculatorCard
   ├─ Selected configuration summary
   ├─ Total meals count
   ├─ Per-meal price
   └─ Final total price

4. SubscribeButton
   - Proceeds to payment
```

---

## 🗄️ Data Models

### ProgramModel (Nutrition)
```dart
{
  id: "prog_123",
  programType: ProgramType.nutrition,
  title: "Healthy Meal Plan",
  description: "...",
  trainer: "Dr. Sarah",
  price: 450.0,
  mealsPerDay: 3,
  daysPerWeek: 5,
  subscriptionMonths: 3,
  // Regular program fields are null/empty
  weeklyDays: [],
  startTime: "",
  programStartDate: null,
  programEndDate: null
}
```

### SubscriptionModel (Nutrition)
```dart
{
  id: "sub_789",
  userId: "user_123",
  programId: "prog_123",
  selectedMealsPerDay: 2,
  selectedDaysPerWeek: 7,
  selectedMonths: 1,
  calculatedPrice: 140.0,
  status: SubscriptionStatus.active,
  startDate: DateTime(2024, 1, 1),
  renewalDate: DateTime(2024, 2, 1)
}
```

---

## ✅ Validation Rules

### Admin Side:
- ✓ Meals per day: Must be 1, 2, or 3
- ✓ Days per week: Must be 3, 5, or 7
- ✓ Duration: Must be 1, 2, 3, 6, or 12 months
- ✓ Price: Must be > 0
- ✓ All fields required

### Customer Side:
- ✓ Must select all three options
- ✓ Cannot subscribe if already subscribed to same program
- ✓ Must have valid payment method

---

## 🚀 Quick Start Checklist

### Phase 1: Admin Creation
- [ ] Add program type selector to program form
- [ ] Show/hide fields based on program type
- [ ] Add nutrition-specific input fields
- [ ] Add price breakdown calculator
- [ ] Test creating nutrition programs

### Phase 2: Customer View
- [ ] Create nutrition program detail screen
- [ ] Add customization selectors
- [ ] Implement real-time price calculation
- [ ] Add subscribe button
- [ ] Test subscription flow

### Phase 3: Data Management
- [ ] Update SubscriptionModel with nutrition fields
- [ ] Save customer selections to Firestore
- [ ] Display in "My Subscriptions"
- [ ] Handle renewals

### Phase 4: Polish
- [ ] Add loading states
- [ ] Add error handling
- [ ] Add success messages
- [ ] Test edge cases
- [ ] Get user feedback

---

**You're all set!** The foundation is complete. Follow this flow to implement the full feature. 🎉
