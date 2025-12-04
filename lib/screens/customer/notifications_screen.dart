import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _classReminders = true;
  bool _promotionalOffers = false;
  bool _newPrograms = true;
  bool _paymentReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Notifications Section
            _buildSectionHeader('General'),
            const SizedBox(height: 12),
            _buildNotificationCard([
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications on your device',
                icon: Icons.notifications_active_outlined,
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Receive updates via email',
                icon: Icons.email_outlined,
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Activity Notifications Section
            _buildSectionHeader('Activity'),
            const SizedBox(height: 12),
            _buildNotificationCard([
              _buildSwitchTile(
                title: 'Class Reminders',
                subtitle: 'Get reminded before your scheduled classes',
                icon: Icons.alarm_outlined,
                value: _classReminders,
                onChanged: (value) {
                  setState(() => _classReminders = value);
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                title: 'Payment Reminders',
                subtitle: 'Reminders for upcoming payments',
                icon: Icons.payment_outlined,
                value: _paymentReminders,
                onChanged: (value) {
                  setState(() => _paymentReminders = value);
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Marketing Notifications Section
            _buildSectionHeader('Marketing'),
            const SizedBox(height: 12),
            _buildNotificationCard([
              _buildSwitchTile(
                title: 'New Programs',
                subtitle: 'Be notified about new programs and classes',
                icon: Icons.new_releases_outlined,
                value: _newPrograms,
                onChanged: (value) {
                  setState(() => _newPrograms = value);
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                title: 'Promotional Offers',
                subtitle: 'Receive special offers and discounts',
                icon: Icons.local_offer_outlined,
                value: _promotionalOffers,
                onChanged: (value) {
                  setState(() => _promotionalOffers = value);
                },
              ),
            ]),

            const SizedBox(height: 32),

            // Recent Notifications Preview
            _buildSectionHeader('Recent Notifications'),
            const SizedBox(height: 12),
            _buildRecentNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildNotificationCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotificationsList() {
    final notifications = [
      _NotificationItem(
        title: 'Class Reminder',
        message: 'Your Yoga class starts in 1 hour',
        time: '2 hours ago',
        icon: Icons.fitness_center,
        isRead: true,
      ),
      _NotificationItem(
        title: 'Payment Successful',
        message: 'Your subscription has been renewed',
        time: '1 day ago',
        icon: Icons.check_circle,
        isRead: true,
      ),
      _NotificationItem(
        title: 'New Program Available',
        message: 'Check out our new Pilates program!',
        time: '3 days ago',
        icon: Icons.new_releases,
        isRead: false,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notification.isRead
                    ? AppColors.secondary
                    : AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.isRead ? AppColors.primary : AppColors.accent,
                size: 24,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            trailing: !notification.isRead
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isRead;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isRead,
  });
}
