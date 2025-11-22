import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../models/center_model.dart';
import '../../providers/firestore_provider.dart';
import '../../services/firestore_service.dart';

class CentersManagementScreen extends ConsumerWidget {
  const CentersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(centersProvider(null)); // Get all centers

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Centers'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: centersAsync.when(
        data: (centers) {
          if (centers.isEmpty) {
            return const Center(
              child: Text('No centers found'),
            );
          }

          // Group centers by status
          final pending = centers.where((c) => c.status == CenterStatus.pending).toList();
          final approved = centers.where((c) => c.status == CenterStatus.approved).toList();
          final rejected = centers.where((c) => c.status == CenterStatus.rejected).toList();

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: AppColors.white,
                  child: TabBar(
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accent,
                    tabs: [
                      Tab(text: 'Pending (${pending.length})'),
                      Tab(text: 'Approved (${approved.length})'),
                      Tab(text: 'Rejected (${rejected.length})'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCentersList(context, pending),
                      _buildCentersList(context, approved),
                      _buildCentersList(context, rejected),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCentersList(BuildContext context, List<CenterModel> centers) {
    if (centers.isEmpty) {
      return const Center(
        child: Text('No centers in this category'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: centers.length,
      itemBuilder: (context, index) {
        final center = centers[index];
        return _buildCenterCard(context, center);
      },
    );
  }

  Widget _buildCenterCard(BuildContext context, CenterModel center) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Center Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    image: center.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(center.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: center.imageUrl.isEmpty
                      ? const Icon(Icons.business, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (center.title != null) ...[
                        Text(
                          center.title!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              center.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(center.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              center.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.fitness_center, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${center.programs.length} Services',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${center.trainers.length} Trainers',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                if (center.status != CenterStatus.approved)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateCenterStatus(context, center.id, CenterStatus.approved),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (center.status != CenterStatus.approved && center.status != CenterStatus.rejected)
                  const SizedBox(width: 8),
                if (center.status != CenterStatus.rejected)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateCenterStatus(context, center.id, CenterStatus.rejected),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (center.status == CenterStatus.approved || center.status == CenterStatus.rejected)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateCenterStatus(context, center.id, CenterStatus.pending),
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Reset to Pending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CenterStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case CenterStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        label = 'Pending';
        icon = Icons.pending;
        break;
      case CenterStatus.approved:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        label = 'Approved';
        icon = Icons.check_circle;
        break;
      case CenterStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCenterStatus(
    BuildContext context,
    String centerId,
    CenterStatus newStatus,
  ) async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.updateCenter(centerId, {
        'status': newStatus.toString().split('.').last,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Center ${newStatus.toString().split('.').last}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
