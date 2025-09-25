import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for managing plant care reminders
class CareRemindersScreen extends ConsumerStatefulWidget {
  final String plantId;
  
  const CareRemindersScreen({super.key, required this.plantId});

  @override
  ConsumerState<CareRemindersScreen> createState() => _CareRemindersScreenState();
}

class _CareRemindersScreenState extends ConsumerState<CareRemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Reminders'),
        backgroundColor: Colors.green[50],
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _RemindersList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add reminder screen
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget displaying the list of care reminders
class _RemindersList extends StatelessWidget {
  const _RemindersList();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 3, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(
                  Icons.water_drop,
                  color: Colors.green[700],
                ),
              ),
              title: Text('Water Plant ${index + 1}'),
              subtitle: const Text('Due in 2 days'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Toggle reminder
                },
                activeColor: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}