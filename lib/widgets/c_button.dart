import 'package:flutter/material.dart';

class CButton extends StatelessWidget {
  final void Function()? onTap;
  final Color? buttonColor;
  final String text;
  const CButton(
      {super.key,
      required this.onTap,
      this.buttonColor = Colors.blue,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: buttonColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
