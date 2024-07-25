import 'dart:convert';
import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/database.dart';
import 'package:project/models/user_model.dart';

import 'package:project/utils/validators.dart';
import 'package:project/widgets/c_textfield.dart';
import 'package:project/widgets/c_button.dart';

import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passController;
  late final TextEditingController _confirmPassController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passController = TextEditingController();
    _confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message,
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

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final password = _passController.text;

      try {
        if (kIsWeb) {
          final response = await http.post(
            Uri.parse('http://localhost:4000/api/v1/user/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'password': password,
            }),
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            _showSnackbar('User created successfully!');
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
            _showSnackbar('Error: ${errorData['msg']}');
          }
        } else if (Platform.isAndroid) {
          String salt = BCrypt.gensalt(logRounds: 10);
          String hashedPassword = BCrypt.hashpw(password, salt);

          User newUser = User(
            userName: name,
            phoneNumber: phone,
            password: hashedPassword,
            email: email,
          );

          final response = await _databaseService.insertUser(newUser);

          if (!mounted) return;

          _showSnackbar(response.msg);

          if (response.statusCode == 200) {
            Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: {
                'name': newUser.userName,
                'phone': newUser.phoneNumber,
                'email': newUser.email,
              },
            );
          } else {
            _showSnackbar(response.msg);
          }
        } else {
          _showSnackbar('Unsupported platform');
        }
      } catch (e) {
        _showSnackbar('Error during sign up: $e');
      }
    } else {
      _showSnackbar('Validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
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
                  controller: _nameController,
                  hint: "Name",
                  validator: nameValidator,
                ),
                const SizedBox(height: 20),
                CTextField(
                  controller: _emailController,
                  hint: "Email",
                  validator: emailValidator,
                ),
                const SizedBox(height: 20),
                CTextField(
                  controller: _phoneController,
                  hint: "Phone",
                  validator: phoneValidator,
                ),
                const SizedBox(height: 20),
                CTextField(
                  controller: _passController,
                  hint: "Create New Password",
                  validator: passwordValidator,
                ),
                const SizedBox(height: 20),
                CTextField(
                  controller: _confirmPassController,
                  hint: "Confirm Your Password",
                  validator: (value) =>
                      confirmPasswordValidator(value, _passController.text),
                ),
                const SizedBox(height: 40),
                CButton(
                  onTap: _handleSignUp,
                  text: "Sign Up",
                ),
                const SizedBox(height: 80),
                const Text(
                  "OR\nAlready have an account?",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CButton(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  text: "Login",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
