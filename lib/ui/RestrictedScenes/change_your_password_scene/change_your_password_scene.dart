import '../../log_in_scene.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dialogs/inform_dialog.dart';
import '../../dialogs/wait_dialog.dart';
import '../../../utilities/Cryptography/my_cryptography_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';

class ChangeYourPasswordScene extends StatelessWidget {
  final DocumentSnapshot user;
  const ChangeYourPasswordScene(this.user, {Key? key}) : super(key: key);

  static get label => "নিজ পাসওয়ার্ড পরিবর্তন";
  static get requiredAdminPrivilege => 'change-own-password';
  static get routeName => 'ChangeYourPasswordScene';

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _newPasswordVerifyController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    ChangeYourPasswordScene.label,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'বর্তমান পাসওয়ার্ড',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'বর্তমান পাসওয়ার্ড লিখেননি';
                      }
                      if (getSHA256Hash(value) !=
                          user.get('passwordSHA256Hash').toString()) {
                        return 'বর্তমান পাসওয়ার্ড ভুল লিখেছেন';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'নতুন পাসওয়ার্ড',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'নতুন পাসওয়ার্ড লিখেননি';
                      }
                      if (value.length < 8) {
                        return 'কমপক্ষে আট ক্যারাক্টার হতে হবে';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _newPasswordVerifyController,
                    decoration: const InputDecoration(
                      labelText: 'নতুন পাসওয়ার্ড আরেকবার',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'নতুন পাসওয়ার্ড আরেকবার লিখেননি';
                      }
                      if (_newPasswordController.text != value) {
                        return 'নতুন পাসওয়ার্ড ঘরের সাথে মিলছে না';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  GFButton(
                    fullWidthButton: true,
                    text: 'পাসওয়ার্ড পরিবর্তন করুন',
                    textStyle: const TextStyle(
                      fontFamily: 'SolaimanLipi',
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      showWaitDialog(context);

                      user.reference.update({
                        'passwordSHA256Hash':
                            getSHA256Hash(_newPasswordController.text),
                        'authenticationTokens': [],
                      }).then((value) async {
                        Navigator.of(context).pop();
                        await showInformDialog(
                            context, 'সফল', 'পাসওয়ার্ড পরিবর্তন হয়েছে।');
                        _formKey.currentState!.reset();
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LogInScene(),
                          ),
                        );
                      }, onError: (error) {
                        showInformDialog(context, 'ব্যর্থ',
                            'পাসওয়ার্ড পরিবর্তন হয়নি। দয়া করে পরে চেষ্টা করুন।');
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
