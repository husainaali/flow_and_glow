# Review System Documentation

## Overview
The Flow & Glow app has a two-tier review system that allows users to review both wellness centers and individual programs.

## Review Types

### 1. Center Reviews
- **Location**: Center Detail Screen → "About us" tab → "Customer Reviews" section
- **Purpose**: Users can review the overall wellness center experience
- **Data Structure**: 
  - `centerId`: ID of the center being reviewed
  - `programId`: `null` (indicates center-level review)
  - `userId`, `userName`, `rating`, `comment`, `createdAt`

### 2. Program Reviews
- **Location**: Program Detail Screen → "Reviews" section
- **Purpose**: Users can review specific programs (e.g., Yoga, Pilates, Nutrition)
- **Data Structure**:
  - `centerId`: ID of the center offering the program
  - `programId`: ID of the specific program being reviewed
  - `userId`, `userName`, `rating`, `comment`, `createdAt`

## Implementation Details

### Center Reviews (`center_detail_screen.dart`)

**Loading Reviews:**
```dart
// Query: Get all reviews for this center
.where('centerId', isEqualTo: centerId)

// Filter: Only show center-level reviews (programId == null)
.where((review) => review.programId == null)
```

**Saving Reviews:**
```dart
ReviewModel(
  centerId: _currentCenter!.id,
  programId: null,  // ← Center-level review
  // ... other fields
)
```

### Program Reviews (`program_detail_screen.dart`)

**Loading Reviews:**
```dart
// Query: Get all reviews for this center
.where('centerId', isEqualTo: widget.program.centerId)

// Filter: Only show reviews for this specific program
.where((review) => review.programId == widget.program.id)
```

**Saving Reviews:**
```dart
ReviewModel(
  centerId: widget.program.centerId,
  programId: widget.program.id,  // ← Program-specific review
  // ... other fields
)
```

## Firebase Structure

### Firestore Collection: `reviews`

```
reviews/
  ├── {reviewId1}
  │   ├── centerId: "center123"
  │   ├── programId: null           ← Center review
  │   ├── userId: "user456"
  │   ├── userName: "John Doe"
  │   ├── rating: 5.0
  │   ├── comment: "Great center!"
  │   └── createdAt: Timestamp
  │
  ├── {reviewId2}
  │   ├── centerId: "center123"
  │   ├── programId: "program789"   ← Program review
  │   ├── userId: "user456"
  │   ├── userName: "John Doe"
  │   ├── rating: 4.5
  │   ├── comment: "Excellent yoga class!"
  │   └── createdAt: Timestamp
```

## User Experience Flow

### Reviewing a Center
1. User navigates to Center Detail Screen
2. Scrolls to "Customer Reviews" section
3. Clicks "Add Review" button
4. Rates the center (1-5 stars) and writes a comment
5. Review is saved with `programId: null`
6. Review appears in the center's review list

### Reviewing a Program
1. User navigates to Program Detail Screen
2. Must be subscribed to the program to see "Add Review" button
3. Clicks "Add Review" button
4. Rates the program (1-5 stars) and writes a comment
5. Review is saved with the specific `programId`
6. Review appears in the program's review list

## Key Features

### Review Eligibility
- **Center Reviews**: Any user can add a review
- **Program Reviews**: Only subscribers can add reviews (checked via `_canAddReview` flag)

### Review Display
- Reviews are sorted by `createdAt` (newest first)
- Limited to 10 most recent reviews per screen
- Empty state shows "No reviews yet" message

### No Index Requirements
Both review queries use simple `where('centerId')` clauses without `orderBy`, avoiding the need for composite Firebase indexes. Sorting and filtering are done client-side in Dart.

## Benefits of This Design

1. **Clear Separation**: Center vs Program reviews are clearly distinguished
2. **Flexible Querying**: Can easily get all reviews for a center or specific program reviews
3. **No Index Overhead**: Simple queries work without custom Firebase indexes
4. **User Context**: Users know exactly what they're reviewing (center or program)
5. **Scalable**: Can add more review types (e.g., trainer reviews) using the same pattern

## Future Enhancements

- Add review editing/deletion functionality
- Implement review moderation
- Add review images
- Show average ratings
- Add helpful/not helpful voting
- Create composite indexes for better performance with large datasets
