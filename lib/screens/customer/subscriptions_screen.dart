import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../models/subscription_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Subscriptions',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please login'));
          }

          final subscriptionsAsync = ref.watch(userSubscriptionsProvider(user.uid));

          return Column(
            children: [
              // Tab selector
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Stack(
                    children: [
                      // Animated background pill
                      AnimatedAlign(
                        alignment: _showActive
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      // Labels and tap areas
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                if (!_showActive) {
                                  setState(() {
                                    _showActive = true;
                                  });
                                }
                              },
                              child: Center(
                                child: Text(
                                  'Active',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _showActive
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                if (_showActive) {
                                  setState(() {
                                    _showActive = false;
                                  });
                                }
                              },
                              child: Center(
                                child: Text(
                                  'Expired',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: !_showActive
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Subscriptions list
              Expanded(
                child: subscriptionsAsync.when(
                  data: (subscriptions) {
                    final filteredSubscriptions = subscriptions.where((sub) {
                      if (_showActive) {
                        return sub.status == SubscriptionStatus.active;
                      } else {
                        return sub.status == SubscriptionStatus.expired ||
                            sub.status == SubscriptionStatus.cancelled;
                      }
                    }).toList();

                    if (filteredSubscriptions.isEmpty) {
                      return const Center(
                        child: Text('No subscriptions found'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredSubscriptions.length,
                      itemBuilder: (context, index) {
                        final subscription = filteredSubscriptions[index];
                        return _buildSubscriptionCard(subscription);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    final isActive = subscription.status == SubscriptionStatus.active;
    final daysUntilRenewal = subscription.renewalDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isActive && subscription.sessionsLeft > 0)
              Text(
                '${subscription.sessionsLeft} sessions left',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            if (!isActive)
              const Text(
                'Not available anymore',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              subscription.packageTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.textPrimary : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'by ${subscription.instructor}',
              style: TextStyle(
                fontSize: 14,
                color: isActive ? AppColors.textSecondary : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${subscription.sessionsPerWeek} Days/week',
              style: TextStyle(
                fontSize: 14,
                color: isActive ? AppColors.textSecondary : AppColors.textLight,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              Text(
                'Renews on ${_formatDate(subscription.renewalDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${subscription.price} ${subscription.currency}/month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.accent : AppColors.textLight,
                  ),
                ),
                ElevatedButton(
                  onPressed: isActive ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    backgroundColor: isActive ? AppColors.accent : AppColors.textLight,
                  ),
                  child: Text(isActive ? 'Manage' : 'Renew'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
