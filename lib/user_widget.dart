import 'package:flutter/material.dart';

Widget customTextIconButton({
  required IconData icon,
  required String text,
  required Function fun,
}) {
  return ElevatedButton(
    onPressed: () => fun(),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.red),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min, // Adjust the width based on content
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0, top: 5, left: 5),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.red),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 7, right: 15),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildTextField({
  required String hintText,
  required TextEditingController controller,
  required FocusNode focusNode,
  FocusNode? nextFocusNode, // Optional: for next field
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(3.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textInputAction: nextFocusNode != null
            ? TextInputAction.next
            : TextInputAction.done,
        onSubmitted: (value) {
          if (value.trim().isEmpty) {
            controller.text = '0';
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
          if (nextFocusNode != null) {
            FocusScope.of(focusNode.context!).requestFocus(nextFocusNode);
          } else {
            focusNode.unfocus(); // No next field? Close keyboard
          }
        },
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.red[200], fontSize: 15),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorStyle: TextStyle(fontSize: 12, color: Colors.redAccent),
        ),
      ),
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
    ),
  );
}