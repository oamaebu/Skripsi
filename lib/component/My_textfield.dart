import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscure;
  final TextEditingController textController;

  // The constructor requires hintText and obscure parameters
  const MyTextfield({
    Key? key,
    required this.hintText,
    required this.obscure,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController, // Assign the controller here
      obscureText: obscure,
      style: TextStyle(color: Colors.black), // Set the text color to black
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hintText,
        hintStyle: TextStyle(color: Color.fromARGB(255, 102, 102, 102)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
