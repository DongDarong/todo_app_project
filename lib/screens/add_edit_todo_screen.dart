import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;

  String _priority = 'low';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.todo?.title ?? '');
    _descController =
        TextEditingController(text: widget.todo?.description ?? '');
    _dateController =
        TextEditingController(text: widget.todo?.date ?? '');

    _priority = widget.todo?.priority ?? 'low';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();

    if (_dateController.text.isNotEmpty) {
      initialDate = DateTime.tryParse(_dateController.text) ?? initialDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'date': _dateController.text,
      'priority': _priority,
    };

    try {
      if (widget.todo == null) {
        // ADD
        await ApiService.addTodo(data);
      } else {
        // UPDATE
        await ApiService.updateTodo({
          'id': widget.todo!.id,
          ...data,
        });
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TITLE
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title required' : null,
              ),

              const SizedBox(height: 16),

              // DESCRIPTION
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // DATE
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Date required' : null,
              ),

              const SizedBox(height: 16),

              // PRIORITY
              DropdownButtonFormField<String>(
                value: _priority,
                items: const [
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('Low'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('High'),
                  ),
                ],
                onChanged: (v) => setState(() => _priority = v!),
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTodo,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(isEdit ? 'Update Todo' : 'Add Todo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
