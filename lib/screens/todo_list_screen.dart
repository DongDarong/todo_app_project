import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/todo.dart';
import 'add_edit_todo_screen.dart';
// import 'history_screen.dart';
import 'login_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    _todosFuture = ApiService.getTodos().then(
      (data) => data.map<Todo>((e) => Todo.fromJson(e)).toList(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadTodos();
    });
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('My Todos'),
  actions: [
    // IconButton(
    //   icon: const Icon(Icons.history),
    //   onPressed: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => const HistoryScreen(),
    //       ),
    //     );
    //   },
    // ),

    PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          await ApiService.clearToken();

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
            (route) => false, 
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'logout',
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  ],
),


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTodoScreen(),
            ),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Todo>>(
          future: _todosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No todos yet 👋\nTap + to add one',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final todos =
                snapshot.data!.where((t) => !t.isDeleted).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    title: Text(
                      todo.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.description != null &&
                            todo.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(todo.description!),
                          ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _priorityColor(todo.priority)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                todo.priority.toUpperCase(),
                                style: TextStyle(
                                  color: _priorityColor(todo.priority),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              todo.date,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditTodoScreen(todo: todo),
                            ),
                          );
                          _refresh();
                        } else if (value == 'delete') {
                          await ApiService.deleteTodo(todo.id);
                          _refresh();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
