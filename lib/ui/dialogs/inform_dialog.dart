import 'package:flutter/material.dart';

Future showInformDialog(BuildContext context, String title, String message) {
  return showDialog(
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
            child: const Text('বেশ!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
