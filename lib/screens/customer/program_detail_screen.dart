import 'package:flow_and_glow/models/program_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review_model.dart';
import '../../models/subscription_model.dart';
import '../../models/session_model.dart';
import '../../utils/app_colors.dart';
import '../../services/schedule_service.dart';
import 'payment_screen.dart' as payment;

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final ProgramModel program;

  const ProgramDetailScreen({
    super.key,
    required this.program,
  });

  @override
  ConsumerState<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  // Mock reviews for now
  List<ReviewModel> _reviews = [];
  
  // Subscription and review state
  bool _isSubscribed = false;
  bool _canAddReview = false;
  bool _isCheckingSubscription = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isCheckingSubscription = false);
      return;
    }

    try {
      // Check if user has an active subscription for this program
      final subscriptionsQuery = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid)
          .where('packageId', isEqualTo: widget.program.id)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (subscriptionsQuery.docs.isNotEmpty) {
        final subscription = SubscriptionModel.fromFirestore(subscriptionsQuery.docs.first);
        setState(() {
          _isSubscribed = true;
          _canAddReview = true; // Subscribers can always add reviews
        });

        // Still check session completion for additional eligibility if needed
        await _checkReviewEligibility(subscription);
      }
    } catch (e) {
      print('Error checking subscription: $e');
    } finally {
      setState(() => _isCheckingSubscription = false);
    }
  }

  Future<void> _checkReviewEligibility(SubscriptionModel subscription) async {
    try {
      // Get all sessions for this subscription
      final sessionsQuery = await FirebaseFirestore.instance
          .collection('sessions')
          .where('userId', isEqualTo: subscription.userId)
          .where('subscriptionId', isEqualTo: subscription.id)
          .get();

      final sessions = sessionsQuery.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();

      if (sessions.isEmpty) return;

      // Count completed sessions
      final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).length;
      final totalSessions = sessions.length;
      final completionPercentage = completedSessions / totalSessions;

      // Check if 50% sessions are completed
      if (completionPercentage >= 0.5) {
        // Find the mid-session date
        final sortedSessions = sessions..sort((a, b) => a.date.compareTo(b.date));
        final midIndex = (totalSessions / 2).floor();
        final midSession = sortedSessions[midIndex];

        // Check if today is after the mid-session date
        final today = DateTime.now();
        final midSessionDate = DateTime(midSession.date.year, midSession.date.month, midSession.date.day);

        if (today.isAfter(midSessionDate) || today.isAtSameMomentAs(midSessionDate)) {
          setState(() => _canAddReview = true);
        }
      }
    } catch (e) {
      print('Error checking review eligibility: $e');
    }
  }

  void _loadReviews() async {
    try {
      final reviewsQuery = await FirebaseFirestore.instance
          .collection('reviews')
          .where('centerId', isEqualTo: widget.program.centerId)
          .get();

      // Filter for program-specific reviews only (programId matches this program)
      final programReviews = reviewsQuery.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .where((review) => review.programId == widget.program.id)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by date descending

      // Take only the first 10 reviews
      final limitedReviews = programReviews.take(10).toList();

      if (mounted) {
        setState(() => _reviews = limitedReviews);
      }
    } catch (e) {
      print('Error loading reviews: $e');
      // Keep empty reviews list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Program Name
          SliverAppBar(
            expandedHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              widget.program.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Program Header Image
                _buildHeaderImage(),
                
                // Program Details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Program Title
                      Text(
                        widget.program.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        widget.program.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Price & Duration
                      _buildPriceAndDuration(),
                      const SizedBox(height: 24),
                      
                      // Trainer Info
                      _buildTrainerInfo(),
                      const SizedBox(height: 24),
                      
                      // Subscribe Button
                      _buildSubscribeButton(),
                      const SizedBox(height: 32),
                      
                      // Reviews Section
                      _buildReviewsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        image: widget.program.headerImageUrl != null && widget.program.headerImageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(widget.program.headerImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.program.headerImageUrl == null || widget.program.headerImageUrl!.isEmpty
          ? const Center(
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }

  Widget _buildPriceAndDuration() {
    return Row(
      children: [
        // Price
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'BHD ${widget.program.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Duration
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.program.durationMinutes} minutes',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trainer Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Trainer Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Trainer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.program.trainer,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lead Instructor',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Schedule Info
        if (widget.program.weeklyDays.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Schedule: ${widget.program.formattedSchedule}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time: ${widget.program.startTime} - ${widget.program.endTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubscribeButton() {
    if (_isCheckingSubscription) {
      return const SizedBox(
        width: double.infinity,
        height: 56,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isSubscribed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Already Subscribed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Subscribe Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to subscribe')),
      );
      return;
    }

    // Navigate to payment screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => payment.PaymentScreen(
          programTitle: widget.program.title,
          price: widget.program.price,
          currency: 'BD',
        ),
      ),
    );

    // Check if payment was successful
    if (result != null && result['success'] == true) {
      await _createSubscriptionAndSchedule();
    }
  }

  Future<void> _createSubscriptionAndSchedule() async {
    final user = FirebaseAuth.instance.currentUser!;
    final scheduleService = ScheduleService();

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 1. Create subscription
      final subscriptionId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      
      final subscription = SubscriptionModel(
        id: subscriptionId,
        userId: user.uid,
        packageId: widget.program.id, // Using program ID as package ID
        packageTitle: widget.program.title,
        instructor: widget.program.trainer,
        price: widget.program.price,
        currency: 'BD',
        sessionsPerWeek: widget.program.weeklyDays.length,
        sessionsLeft: 0, // Will be calculated from sessions
        status: SubscriptionStatus.active,
        paymentMethod: PaymentMethod.online,
        startDate: now,
        renewalDate: now.add(const Duration(days: 30)),
        createdAt: now,
      );

      // 2. Save subscription to Firestore
      await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(subscription.id)
          .set(subscription.toFirestore());

      // 3. Generate schedule based on program type
      List<SessionModel> sessions;

      if (widget.program.programType == ProgramType.regular) {
        // Regular program - generate sessions based on weekly schedule
        sessions = await scheduleService.generateRegularProgramSessions(
          subscriptionId: subscription.id,
          userId: user.uid,
          program: widget.program,
          startDate: widget.program.programStartDate ?? now,
          endDate: widget.program.programEndDate ?? now.add(const Duration(days: 90)),
        );
      } else {
        // Nutrition program - generate meal delivery sessions
        // TODO: Get these values from customer selection
        sessions = await scheduleService.generateNutritionProgramSessions(
          subscriptionId: subscription.id,
          userId: user.uid,
          program: widget.program,
          selectedMonths: widget.program.subscriptionMonths ?? 3,
          selectedDaysPerWeek: widget.program.daysPerWeek ?? 5,
          selectedMealsPerDay: widget.program.mealsPerDay ?? 3,
        );
      }

      // 4. Save all sessions to Firestore
      await scheduleService.saveSessions(sessions);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // 5. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription created! ${sessions.length} sessions scheduled.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // 6. Navigate back or to calendar
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddReviewDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rate this program:'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1.0);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a comment')),
                  );
                  return;
                }

                await _saveReview(rating, commentController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReview(double rating, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.exists 
          ? (userDoc.data()?['name'] ?? 'Anonymous')
          : 'Anonymous';

      final review = ReviewModel(
        id: '',
        userId: user.uid,
        userName: userName,
        userImageUrl: '',
        centerId: widget.program.centerId,
        programId: widget.program.id,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.toFirestore());

      // Reload reviews to show the new one
      _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                if (_canAddReview)
                  TextButton.icon(
                    onPressed: _showAddReviewDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Review'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          // Reviews List
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(_reviews[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Stars
          Row(
            children: List.generate(5, (index) {
              final fullStars = review.rating.floor();
              final hasHalfStar = review.rating - fullStars >= 0.5;
              
              if (index < fullStars) {
                return const Icon(Icons.star, size: 16, color: Colors.amber);
              } else if (index == fullStars && hasHalfStar) {
                return const Icon(Icons.star_half, size: 16, color: Colors.amber);
              } else {
                return const Icon(Icons.star_border, size: 16, color: Colors.amber);
              }
            }),
          ),
          const SizedBox(height: 8),
          
          // User Name
          Text(
            review.userName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Comment
          Expanded(
            child: Text(
              review.comment,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
