import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

Future showWaitDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        title: Text(
          'দয়া করে কিছুক্ষণ অপেক্ষা করুন।',
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: 40.0,
          child: GFLoader(
              type:GFLoaderType.circle,
            size: GFSize.SMALL,
          ),
        ),
      );
    },
  );
}