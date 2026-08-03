import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/offline_storage.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'exam_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = <Task>[];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _taskGoal = 5;
  DateTime _calendarSelectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await OfflineStorage.loadTasks();
    final taskGoal = await OfflineStorage.loadTaskGoal();
    if (!mounted) return;

    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks);
      _taskGoal = taskGoal;
      _isLoading = false;
    });
  }

  Future<void> _saveGoal(int value) async {
    await OfflineStorage.saveTaskGoal(value);
    if (!mounted) return;
    setState(() {
      _taskGoal = value;
    });
  }

  Future<void> _openAddTaskSheet() async {
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    bool isExam = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New task',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final today = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? today,
                              firstDate:
                                  today.subtract(const Duration(days: 365)),
                              lastDate: today.add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              sheetSetState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            selectedDate == null
                                ? 'Pick deadline'
                                : _formatDueDate(selectedDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Exam task'),
                          value: isExam,
                          onChanged: (value) {
                            sheetSetState(() {
                              isExam = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final description = descriptionController.text.trim();
                      if (description.isEmpty || selectedDate == null) {
                        return;
                      }

                      final newTask = Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        description: description,
                        dueDate: selectedDate!,
                        isExam: isExam,
                      );

                      final navigator = Navigator.of(context);
                      await OfflineStorage.addTask(newTask);
                      if (!mounted) return;
                      navigator.pop();
                      await _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save task'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _changeGoal() async {
    final controller = TextEditingController(text: _taskGoal.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set your goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tasks to complete',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0) {
      await _saveGoal(result);
    }
  }

  Future<void> _toggleTaskDone(Task task) async {
    final updatedTask = task.copyWith(isDone: !task.isDone);
    await OfflineStorage.updateTask(updatedTask);
    await _loadData();
  }

  Future<void> _removeTask(String taskId) async {
    await OfflineStorage.removeTask(taskId);
    await _loadData();
  }

  String _formatDueDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }

  Widget _buildTasksTab() {
    final upcomingTasks = _tasks.where((task) => !task.isDone).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tasks',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openAddTaskSheet,
                icon: const Icon(Icons.add),
                label: const Text('New task'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryChips(tasks: _tasks),
          const SizedBox(height: 20),
          const Text(
            'Upcoming tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : upcomingTasks.isEmpty
                    ? const Center(
                        child: Text('No tasks yet. Add a task to get started.'),
                      )
                    : ListView.separated(
                        itemCount: upcomingTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = upcomingTasks[index];
                          return _TaskCard(
                            task: task,
                            onToggleDone: _toggleTaskDone,
                            onDelete: _removeTask,
                            formatDate: _formatDueDate,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(
        tasks: _tasks,
        taskGoal: _taskGoal,
        onChangeGoal: _changeGoal,
      ),
      _buildTasksTab(),
      ExamPage(
        tasks: _tasks,
        onToggleDone: _toggleTaskDone,
        onDelete: _removeTask,
      ),
      CalendarPage(
        tasks: _tasks,
        selectedDate: _calendarSelectedDate,
        onDateSelected: (date) {
          setState(() {
            _calendarSelectedDate = date;
          });
        },
        onToggleDone: _toggleTaskDone,
        onDelete: _removeTask,
      ),
    ];

    final drawerItems = <_DrawerItem>[
      const _DrawerItem(icon: Icons.dashboard, title: 'Dashboard', index: 0),
      const _DrawerItem(icon: Icons.checklist_rtl, title: 'Tasks', index: 1),
      const _DrawerItem(icon: Icons.school, title: 'Exam', index: 2),
      const _DrawerItem(
          icon: Icons.calendar_today, title: 'Calendar', index: 3),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyStudyLife'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Study planner',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              for (final item in drawerItems)
                ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  selected: _currentIndex == item.index,
                  selectedTileColor:
                      const Color(0xFF6C63FF).withValues(alpha: 0.12),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectPage(item.index);
                  },
                ),
            ],
          ),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey.shade600,
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Exam',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;
  final int index;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}

class _SummaryChips extends StatelessWidget {
  final List<Task> tasks;

  const _SummaryChips({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.isDone).length;
    final pending = tasks.where((task) => !task.isDone).length;
    final exams = tasks.where((task) => task.isExam).length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatChip(
            label: 'Completed',
            value: completed.toString(),
            color: Colors.green),
        _StatChip(
            label: 'Pending', value: pending.toString(), color: Colors.orange),
        _StatChip(
            label: 'Exam tasks', value: exams.toString(), color: Colors.purple),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withValues(alpha: 0.12),
      label: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final Future<void> Function(Task task) onToggleDone;
  final Future<void> Function(String taskId) onDelete;
  final String Function(DateTime) formatDate;

  const _TaskCard({
    required this.task,
    required this.onToggleDone,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: task.isDone, onChanged: (_) => onToggleDone(task)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (task.isExam)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Exam',
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (task.isExam) const SizedBox(width: 10),
                      Text(
                        'Due ${formatDate(task.dueDate)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => onDelete(task.id),
            ),
          ],
        ),
      ),
    );
  }
}
