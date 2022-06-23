import '../utilities/JSON/my_json_utilities.dart';
import '../utilities/cryptography/my_cryptography_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RestrictedScenes/restricted_scenes.dart';
import 'dialogs/inform_dialog.dart';
import 'dialogs/wait_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class LogInScene extends StatelessWidget {
  const LogInScene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: GFCard(
                elevation: 8.0,
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'এডমিন ইউজারনেম লিখুন',
                        ),
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty) {
                            return 'ইউজারনেম লিখেননি';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'পাসওয়ার্ড লিখুন',
                        ),
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty) {
                            return 'পাসওয়ার্ড লিখেননি';
                          }
                          return null;
                        },
                      ),
                      GFButton(
                        child: const Text(
                          'লগ ইন করুন',
                          style: TextStyle(
                            fontFamily: 'SolaimanLipi',
                          ),
                        ),
                        fullWidthButton: true,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          showWaitDialog(context);
                          DocumentSnapshot admin = await FirebaseFirestore
                              .instance
                              .collection('admins')
                              .doc(_usernameController.text)
                              .get();

                          if (!admin.exists) {
                            Navigator.of(context).pop();
                            showInformDialog(context, 'ভুল হচ্ছে',
                                'এই ইউজারনেমের কোনো এডমিন নেই।');
                            return;
                          }
                          if (admin.get('passwordSHA256Hash').toString() !=
                              getSHA256Hash(_passwordController.text)) {
                            Navigator.of(context).pop();
                            showInformDialog(
                                context, 'ভুল হচ্ছে', 'পাসওয়ার্ড সঠিক নয়।');
                            return;
                          }

                          String authenticationToken = _usernameController
                                  .text +
                              _passwordController.text +
                              DateTime.now().millisecondsSinceEpoch.toString();
                          authenticationToken =
                              getSHA256Hash(authenticationToken);

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          List<String> authenticationTokens = [];
                          try {
                            authenticationTokens = getListFromJSONArray(
                                admin.get('authenticationTokens'));
                          } catch (error) {
                            1;
                          }

                          String? currentTokenOnThisDevice;

                          try {
                            currentTokenOnThisDevice =
                                prefs.getString('authenticationToken');
                          } catch (error) {
                            1;
                          }

                          if (currentTokenOnThisDevice != null) {
                            authenticationTokens
                                .remove(currentTokenOnThisDevice);
                          }

                          if (!await prefs.setString(
                              'authenticationToken', authenticationToken)) {
                            Navigator.of(context).pop();
                            showInformDialog(context, 'দুঃখিত',
                                'আপনার ডিভাইসে কোনো সমস্যা হচ্ছে। দয়া করে পরে চেষ্টা করুন।');
                            return;
                          }

                          authenticationTokens.add(authenticationToken);

                          admin.reference.update({
                            'authenticationTokens': authenticationTokens,
                          }).then((value) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RestrictedScenes(admin),
                              ),
                            );
                          }, onError: (error) {
                            Navigator.of(context).pop();
                            showInformDialog(context, 'দুঃখিত',
                                'ডাটাবেস সার্ভারে কোনো সমস্যা হচ্ছে। দয়া করে পরে চেষ্টা করুন।');
                            return;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
