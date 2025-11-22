import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../customer/center_detail_screen.dart';

/// Center Preview Screen for Center Admins
/// This screen is a wrapper around CenterDetailScreen in preview mode.
/// It allows center admins to preview how their center page looks to customers
/// and provides an edit button to modify their center profile.
class CenterPreviewScreen extends ConsumerWidget {
  const CenterPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CenterDetailScreen(
      isPreviewMode: true,
    );
  }
}
