import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for viewing and managing plant care logs
class CareLogsScreen extends ConsumerStatefulWidget {
  final String plantId;
  
  const CareLogsScreen({super.key, required this.plantId});

  @override
  ConsumerState<CareLogsScreen> createState() => _CareLogsScreenState();
}

class _CareLogsScreenState extends ConsumerState<CareLogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Logs'),
        backgroundColor: Colors.green[50],
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _CareLogsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add care log screen
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget displaying the list of care logs
class _CareLogsList extends StatelessWidget {
  const _CareLogsList();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          final careTypes = ['Watered', 'Fertilized', 'Pruned', 'Repotted', 'Checked'];
          final careType = careTypes[index % careTypes.length];
          final icons = {
            'Watered': Icons.water_drop,
            'Fertilized': Icons.eco,
            'Pruned': Icons.content_cut,
            'Repotted': Icons.local_florist,
            'Checked': Icons.visibility,
          };
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(
                  icons[careType] ?? Icons.local_florist,
                  color: Colors.green[700],
                ),
              ),
              title: Text(careType),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plant ${index + 1}'),
                  Text(
                    '${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Show options menu
                },
              ),
            ),
          );
        },
      ),
    );
  }
}