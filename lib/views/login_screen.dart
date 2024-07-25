import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/database.dart';
import 'package:project/utils/validators.dart';
import 'package:project/widgets/c_button.dart';
import 'package:project/widgets/c_textfield.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  late final TextEditingController _phoneController;
  late final TextEditingController _passController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text;
      final password = _passController.text;

      try {
        if (kIsWeb) {
          final response = await http.post(
            Uri.parse('http://localhost:4000/api/v1/user/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'phone': phone,
              'password': password,
            }),
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);

            _showSnackBar('Login successful!');
            Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: {
                'name': responseData['data']['name'].toString(),
                'phone': responseData['data']['phone'].toString(),
                'email': responseData['data']['email'].toString(),
              },
            );
          } else {
            final errorData = jsonDecode(response.body);
            _showSnackBar('Error: ${errorData['msg']}');
          }
        } else if (Platform.isAndroid) {
          final response = await _databaseService.loginUser(phone, password);

          if (!mounted) return;

          _showSnackBar(response.msg);

          if (response.statusCode == 200) {
            Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: response.data,
            );
          } else {
            _showSnackBar(response.msg);
          }
        } else {
          _showSnackBar('Unsupported platform');
        }
      } catch (e) {
        _showSnackBar('Error during login: $e');
      }
    } else {
      _showSnackBar('Validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        shadowColor: const Color.fromARGB(255, 198, 198, 198),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CTextField(
                  controller: _phoneController,
                  hint: "Phone",
                  validator: (value) => phoneValidator(value),
                ),
                const SizedBox(height: 20),
                CTextField(
                  controller: _passController,
                  hint: "Password",
                  validator: (value) => passwordValidator(value),
                ),
                const SizedBox(height: 40),
                CButton(
                  onTap: _handleLogin,
                  text: "Login",
                ),
                const SizedBox(height: 80),
                const Text(
                  "OR\nDon't have an account?",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CButton(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  text: "SignUp",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
