import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List todos = [];
  bool loading = true;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String priority = "medium";

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final data = await ApiService.getTodos();
    if (!mounted) return;
    setState(() {
      todos = data;
      loading = false;
    });
  }

  Future<void> addTodo() async {
    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) return;

    await ApiService.addTodo(
      title: titleCtrl.text,
      description: descCtrl.text,
      priority: priority,
    );

    titleCtrl.clear();
    descCtrl.clear();
    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todo List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
                DropdownButtonFormField(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: "low", child: Text("Low")),
                    DropdownMenuItem(value: "medium", child: Text("Medium")),
                    DropdownMenuItem(value: "high", child: Text("High")),
                  ],
                  onChanged: (v) => setState(() => priority = v!),
                  decoration: const InputDecoration(labelText: "Priority"),
                ),
                ElevatedButton(onPressed: addTodo, child: const Text("Add Todo")),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (_, i) {
                      final t = todos[i];
                      return ListTile(
                        title: Text(t["title"]),
                        subtitle: Text("${t["description"]} • ${t["priority"]}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await ApiService.deleteTodo(t["id"]);
                            loadTodos();
                          },
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
