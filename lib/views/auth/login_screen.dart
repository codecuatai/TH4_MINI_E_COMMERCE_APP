import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => _email = v,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Email không hợp lệ',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                onChanged: (v) => _password = v,
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'Mật khẩu tối thiểu 6 ký tự',
              ),
              const SizedBox(height: 24),
              if (authController.error != null)
                Text(
                  authController.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: authController.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await authController.login(_email, _password);
                        }
                      },
                child: authController.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đăng nhập'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Chưa có tài khoản? Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
