import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To-Do App",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const TodoHomePage(),
    );
  }
}

class Task {
  String title;
  bool isDone;
  String priority;

  Task({required this.title, this.isDone = false, this.priority = "Medium"});
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> tasks = [];
  final TextEditingController controller = TextEditingController();
  String filter = "All";
  void addTask(String title, String priority) {
    setState(() {
      tasks.add(Task(title: title.trim(), priority: priority));
      sortByPriority();
    });
    controller.clear();
  }

  void sortByPriority() {
    const order = {"High": 1, "Medium": 2, "Low": 3};
    tasks.sort((a, b) => order[a.priority]!.compareTo(order[b.priority]!));
  }

  List<Task> get filteredTasks {
    switch (filter) {
      case "Done":
        return tasks.where((t) => t.isDone).toList();
      case "Pending":
        return tasks.where((t) => !t.isDone).toList();
      default:
        return tasks;
    }
  }

  Color priorityColor(String p) {
    switch (p) {
      case "High":
        return Colors.redAccent;
      case "Medium":
        return Colors.orangeAccent;
      case "Low":
        return Colors.greenAccent;
      default:
        return Colors.white;
    }
  }

  Future<void> showAddDialog() async {
    String priority = "Medium";
    String? errorMsg;
    bool taskAdded = false;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: StatefulBuilder(
            builder: (context, setDialog) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(59, 255, 255, 255),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Task name...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color.fromARGB(123, 32, 32, 32),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: priority,
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(255, 24, 24, 24),
                    style: const TextStyle(color: Colors.white),
                    items: ["High", "Medium", "Low"]
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setDialog(() => priority = val!),
                  ),

                  const SizedBox(height: 12),

                  if (errorMsg != null)
                    Text(errorMsg!, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isEmpty) {
                        setDialog(() => errorMsg = "Enter a task name");
                        return;
                      }
                      setState(() {
                        tasks.add(
                          Task(title: controller.text, priority: priority),
                        );
                        sortByPriority();
                      });
                      setDialog(() {
                        controller.clear();
                        errorMsg = null;
                        taskAdded = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Add Task"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade400,
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("To-Do"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => setState(sortByPriority),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["All", "Done", "Pending"]
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: filter == f,
                      onSelected: (_) => setState(() => filter = f),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      "No tasks yet",
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    padding: const EdgeInsets.all(14),
                    itemBuilder: (_, i) {
                      final task = filteredTasks[i];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (_) =>
                                setState(() => task.isDone = !task.isDone),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: priorityColor(task.priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_sharp,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    setState(() => tasks.remove(task)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Made by Adel Naim",
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }
}
