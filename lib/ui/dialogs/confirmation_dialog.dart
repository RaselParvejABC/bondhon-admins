import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(BuildContext context, String title, String message) async {
  bool response = false;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('হ্যাঁ'),
            onPressed: () {
              response = true;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('না'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  return response;
}
