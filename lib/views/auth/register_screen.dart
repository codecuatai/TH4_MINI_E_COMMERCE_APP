import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
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
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nhập lại mật khẩu',
                ),
                obscureText: true,
                onChanged: (v) => _confirmPassword = v,
                validator: (v) => v == _password ? null : 'Mật khẩu không khớp',
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
                          await authController.register(_email, _password);
                          if (authController.isLoggedIn) {
                            Navigator.pop(context);
                          }
                        }
                      },
                child: authController.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
