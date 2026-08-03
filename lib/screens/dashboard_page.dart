import 'package:flutter/material.dart';
import '../models/task.dart';

class DashboardPage extends StatelessWidget {
  final List<Task> tasks;
  final int taskGoal;
  final VoidCallback onChangeGoal;

  const DashboardPage({
    super.key,
    required this.tasks,
    required this.taskGoal,
    required this.onChangeGoal,
  });

  @override
  Widget build(BuildContext context) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isDone).length;
    final incompleteTasks = totalTasks - completedTasks;
    final examTasks = tasks.where((task) => task.isExam).length;
    final goalProgress =
        taskGoal == 0 ? 0.0 : (completedTasks / taskGoal).clamp(0.0, 1.0);

    Widget buildStatCard(String label, String value, Color color) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Analyze your task progress and goal completion at a glance.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              buildStatCard(
                  'Completed', completedTasks.toString(), Colors.green),
              const SizedBox(width: 12),
              buildStatCard(
                  'Incomplete', incompleteTasks.toString(), Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              buildStatCard('Total', totalTasks.toString(), Colors.blue),
              const SizedBox(width: 12),
              buildStatCard('Exam', examTasks.toString(), Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F6), Color(0xFFEFEFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Goal progress',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: onChangeGoal,
                        child: const Text('Edit goal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Complete $taskGoal tasks',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 24,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: goalProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${(goalProgress * 100).round()}% complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Goal',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$taskGoal tasks',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedTasks tasks',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
