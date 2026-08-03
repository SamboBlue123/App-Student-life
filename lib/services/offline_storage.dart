import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class OfflineStorage {
  static const _tasksKey = 'offline_tasks';
  static const _goalKey = 'task_goal';
  static const _notesKey = 'offline_notes';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    final tasks = Task.decodeList(raw);
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, Task.encodeList(tasks));
  }

  static Future<List<String>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_notesKey) ?? <String>[];
  }

  static Future<void> addNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await loadNotes();
    notes.add(note);
    await prefs.setStringList(_notesKey, notes);
  }

  static Future<void> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  static Future<void> updateTask(Task updatedTask) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  static Future<void> removeTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  static Future<int> loadTaskGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalKey) ?? 5;
  }

  static Future<void> saveTaskGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalKey, goal);
  }
}
