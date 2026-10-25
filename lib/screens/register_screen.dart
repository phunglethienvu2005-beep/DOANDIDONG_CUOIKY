import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
    await DatabaseHelper.instance.registerUser(
      usernameController.text,
      emailController.text,
      passwordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đăng ký thành công")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: register,
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}