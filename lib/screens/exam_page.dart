import 'package:flutter/material.dart';
import '../models/task.dart';

class ExamPage extends StatelessWidget {
  final List<Task> tasks;
  final Future<void> Function(Task task) onToggleDone;
  final Future<void> Function(String taskId) onDelete;

  const ExamPage({
    super.key,
    required this.tasks,
    required this.onToggleDone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final examTasks = tasks.where((task) => task.isExam).toList();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam Plan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track upcoming exam tasks and mark them complete when ready.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: examTasks.isEmpty
                ? const Center(
                    child: Text('No exam tasks yet. Add one from Tasks.'),
                  )
                : ListView.separated(
                    itemCount: examTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = examTasks[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (_) => onToggleDone(task),
                          ),
                          title: Text(
                            task.description,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                              'Due ${task.dueDate.toLocal()}'.split(' ')[0]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => onDelete(task.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
