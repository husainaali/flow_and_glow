# Review System - User Guide

## ✅ Two Separate Review Systems Implemented

Your app now has **two independent review systems** working correctly:

---

## 1️⃣ **CENTER REVIEWS** 
### Write a review about the wellness center overall

**📍 Where to find it:**
```
Customer Home → Select a Center → "About us" tab → Scroll to "Customer Reviews"
```

**🎯 What it reviews:**
- The wellness center as a whole
- Overall facility quality
- General customer service
- Center atmosphere and cleanliness

**💾 How it's saved:**
```dart
ReviewModel(
  centerId: "center123",
  programId: null,           // ← NULL means center review
  userId: "user456",
  userName: "John Doe",
  rating: 5.0,
  comment: "Amazing wellness center! Great facilities and friendly staff."
)
```

**👤 Who can review:**
- Any user (no subscription required)

**📱 UI Elements:**
- Button: **"Add Review"** (always visible)
- Dialog title: **"Add Review"**
- Rating prompt: **"Rate this center:"**

---

## 2️⃣ **PROGRAM REVIEWS**
### Write a review about a specific program (Yoga, Pilates, etc.)

**📍 Where to find it:**
```
Customer Home → Select a Center → Select a Program → Scroll to "Reviews"
```

**🎯 What it reviews:**
- The specific program (e.g., "Morning Yoga", "Pilates Basics")
- Instructor quality for that program
- Program content and effectiveness
- Class schedule and duration

**💾 How it's saved:**
```dart
ReviewModel(
  centerId: "center123",
  programId: "yoga789",      // ← Program ID means program review
  userId: "user456",
  userName: "John Doe",
  rating: 4.5,
  comment: "Excellent yoga class! The instructor is very knowledgeable."
)
```

**👤 Who can review:**
- Only subscribers to that specific program
- Must have an active subscription

**📱 UI Elements:**
- Button: **"Add Review"** (only visible if subscribed)
- Dialog title: **"Add Review"**
- Rating prompt: **"Rate this program:"**

---

## 📊 **How Reviews Are Separated**

### Database Structure:
```
reviews/
  ├── review1 → { centerId: "center123", programId: null }        ← Center review
  ├── review2 → { centerId: "center123", programId: "yoga789" }   ← Program review
  ├── review3 → { centerId: "center123", programId: "pilates456" } ← Program review
  └── review4 → { centerId: "center456", programId: null }        ← Center review
```

### Loading Logic:

**Center Detail Screen:**
```dart
// Get all reviews for this center
.where('centerId', isEqualTo: centerId)

// Filter: Only show reviews where programId is NULL
.where((review) => review.programId == null)
```

**Program Detail Screen:**
```dart
// Get all reviews for this center
.where('centerId', isEqualTo: centerId)

// Filter: Only show reviews for THIS specific program
.where((review) => review.programId == widget.program.id)
```

---

## 🎬 **User Experience Flow**

### Scenario 1: Reviewing "Serenity Wellness Center"
1. User visits **Serenity Wellness Center** detail page
2. Scrolls to **"Customer Reviews"** section
3. Clicks **"Add Review"**
4. Rates 5 stars: "Great center with excellent facilities!"
5. ✅ Review saved with `programId: null`
6. ✅ Review appears in **center's review list**
7. ❌ Review does NOT appear in any program's review list

### Scenario 2: Reviewing "Morning Yoga" Program
1. User subscribes to **"Morning Yoga"** at Serenity Wellness Center
2. Opens **"Morning Yoga"** program detail page
3. Scrolls to **"Reviews"** section
4. Clicks **"Add Review"** (visible because subscribed)
5. Rates 4 stars: "Excellent instructor and great morning routine!"
6. ✅ Review saved with `programId: "yoga123"`
7. ✅ Review appears in **Morning Yoga's review list**
8. ❌ Review does NOT appear in center's general reviews
9. ❌ Review does NOT appear in other programs' reviews

---

## 🔍 **Key Differences**

| Feature | Center Reviews | Program Reviews |
|---------|---------------|-----------------|
| **Location** | Center Detail → About us tab | Program Detail → Reviews section |
| **Access** | Anyone can review | Only subscribers |
| **programId** | `null` | Specific program ID |
| **Reviews** | About the center | About the program |
| **Visibility** | Only on center page | Only on that program page |

---

## ✨ **Benefits**

1. **Clear Separation**: Users know exactly what they're reviewing
2. **Relevant Feedback**: Center reviews vs program-specific feedback
3. **Better Decisions**: Users can see both general center quality and specific program quality
4. **Flexible**: Can review center without subscribing, or review specific programs after subscribing

---

## 🧪 **Testing Checklist**

### Test Center Reviews:
- [ ] Navigate to any center detail page
- [ ] Find "Customer Reviews" section in "About us" tab
- [ ] Click "Add Review" button
- [ ] Submit a review with rating and comment
- [ ] Verify review appears in center's review list
- [ ] Verify review does NOT appear in any program's review list

### Test Program Reviews:
- [ ] Subscribe to a program
- [ ] Navigate to that program's detail page
- [ ] Find "Reviews" section
- [ ] Click "Add Review" button (should be visible)
- [ ] Submit a review with rating and comment
- [ ] Verify review appears in program's review list
- [ ] Verify review does NOT appear in center's general reviews
- [ ] Verify review does NOT appear in other programs' reviews

---

## 🎯 **Summary**

✅ **You have TWO working review systems:**

1. **Center Reviews** (`programId: null`) - For reviewing the wellness center
2. **Program Reviews** (`programId: "xyz"`) - For reviewing specific programs

Both are completely separate and work independently! 🎉
