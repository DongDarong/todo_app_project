import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ApiService.register(userCtrl.text, passCtrl.text);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
