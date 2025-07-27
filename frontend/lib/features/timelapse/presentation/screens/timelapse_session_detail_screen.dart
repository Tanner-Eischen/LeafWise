import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plant_social/features/timelapse/presentation/widgets/growth_analysis_widget.dart';

class TimelapseSessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const TimelapseSessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a placeholder. We will fetch the session details later.
    // final sessionAsync = ref.watch(timelapseSessionProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GrowthAnalysisWidget(sessionId: sessionId),
          ],
        ),
      ),
    );
  }
}