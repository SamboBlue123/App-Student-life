import 'package:flutter/material.dart';
import '../models/task.dart';

class CalendarPage extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDate;
  final void Function(DateTime date) onDateSelected;
  final Future<void> Function(Task task) onToggleDone;
  final Future<void> Function(String taskId) onDelete;

  const CalendarPage({
    super.key,
    required this.tasks,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onToggleDone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dailyTasks = tasks.where((task) {
      return task.dueDate.year == selectedDate.year &&
          task.dueDate.month == selectedDate.month &&
          task.dueDate.day == selectedDate.day;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calendar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a day to see tasks and exam plans scheduled for that date.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      onDateSelected(picked);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C4DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Selected: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: dailyTasks.isEmpty
                ? const Center(
                    child: Text('No tasks scheduled for this date.'),
                  )
                : ListView.separated(
                    itemCount: dailyTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = dailyTasks[index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF2F7), Color(0xFFF7F0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (_) => onToggleDone(task),
                          ),
                          title: Text(
                            task.description,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(task.isExam ? 'Exam task' : 'Task'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
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
