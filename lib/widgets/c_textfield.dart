import 'package:flutter/material.dart';

class CTextField extends StatefulWidget {
  final String hint;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  const CTextField({
    super.key,
    required this.hint,
    this.validator,
    required this.controller,
  });

  @override
  _CTextFieldState createState() => _CTextFieldState();
}

class _CTextFieldState extends State<CTextField> {
  bool _showPass = true;

  TextInputType _getKeyboardType() {
    switch (widget.hint) {
      case "Name":
        return TextInputType.name;
      case "Password":
      case "Confirm Password":
        return TextInputType.visiblePassword;
      case "Email":
        return TextInputType.emailAddress;
      case "Phone":
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      keyboardType: _getKeyboardType(),
      obscureText: widget.hint.contains("Password") ? _showPass : false,
      controller: widget.controller,
      validator: widget.validator,
      decoration: InputDecoration(
        suffixIcon: widget.hint == "Password"
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _showPass = !_showPass;
                  });
                },
                icon: Icon(_showPass ? Icons.remove_red_eye : Icons.close),
              )
            : null,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
