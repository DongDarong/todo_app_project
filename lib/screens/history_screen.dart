// import 'package:flutter/material.dart';
// import '../models/todo.dart';
// import '../services/api_service.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   late Future<List<Todo>> _historyFuture;

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   void _loadHistory() {
//     _historyFuture = ApiService.getTodos().then(
//       (data) => data
//           .map<Todo>((e) => Todo.fromJson(e))
//           .where((todo) => todo.isDeleted)
//           .toList(),
//     );
//   }

//   void _refresh() {
//     if (!mounted) return;
//     setState(() {
//       _loadHistory();
//     });
//   }

//   // ================= RESTORE PLACEHOLDER =================
//   Future<void> _restoreTodo() async {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Restore requires backend soft delete support',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Deleted Todos'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async => _refresh(),
//         child: FutureBuilder<List<Todo>>(
//           future: _historyFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             // ================= EMPTY STATE =================
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Text(
//                     'No deleted todos 🧹\n\n'
//                     'History requires backend soft delete support.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 15),
//                   ),
//                 ),
//               );
//             }

//             final history = snapshot.data!;

//             return ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: history.length,
//               itemBuilder: (context, index) {
//                 final todo = history[index];

//                 return Card(
//                   elevation: 2,
//                   margin: const EdgeInsets.only(bottom: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     title: Text(
//                       todo.title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (todo.description != null &&
//                             todo.description!.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(todo.description!),
//                           ),
//                         const SizedBox(height: 6),
//                         Text(
//                           'Deleted at: ${todo.deletedAt ?? "Unknown"}',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                     trailing: ElevatedButton.icon(
//                       onPressed: _restoreTodo,
//                       icon: const Icon(Icons.restore),
//                       label: const Text('Restore'),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
