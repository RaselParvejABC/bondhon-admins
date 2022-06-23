import 'package:bondhonmuradnagar/utilities/JSON/my_json_utilities.dart';

import '../../log_in_scene.dart';

import '../admin_management_scene/authentication.dart';
import 'blood_groups_list.dart';
import '../../dialogs/inform_dialog.dart';
import '../../dialogs/wait_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:sanitize_html/sanitize_html.dart';

class AddNewMemberWidget extends StatelessWidget {
  final DocumentSnapshot admin;
  const AddNewMemberWidget(this.admin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<String> adminPrivileges = getListFromJSONArray(admin.get('privileges'));

    if(!adminPrivileges.contains('member-add')){
      return const Text('নতুন রক্তদাতা এন্ট্রি করার ক্ষমতা আপনার নেই।');
    }

    final _formKey = GlobalKey<FormState>();

    final _memberIDController = TextEditingController();
    final _nameInBanglaLettersController = TextEditingController();
    final _nameInEnglishLettersController = TextEditingController();
    String? selectedBloodGroup;
    String lastDonationDate = "1900-01-01";
    final _phoneNumbersController = TextEditingController();
    List<String> phoneNumbers = [];
    final _fbProfileLinkController = TextEditingController();
    final _fatherOrHusbandNameController = TextEditingController();
    final _motherNameController = TextEditingController();
    String? birthDate;
    final _professionController = TextEditingController();
    final _villageController = TextEditingController();
    final _postController = TextEditingController();
    final _upazillaController = TextEditingController();
    final _districtController = TextEditingController();


    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'নতুন রক্তদাতা',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          ElevatedButton(
            child: const Text('ডাটাবেসে সেভ করুন'),
            onPressed: () async {
              if (!(await isSavedAuthenticationTokenValid(admin))) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => const LogInScene()),
                  (route) => false,
                );
                return;
              }

              if (!_formKey.currentState!.validate()) {
                await showInformDialog(
                    context, 'ভুল করছেন', 'সব তথ্য ঠিকঠাক পূরণ করেননি।');
                return;
              }

              DocumentSnapshot donor = await FirebaseFirestore.instance
                  .collection('donors')
                  .doc(_memberIDController.text)
                  .get();

              if (donor.exists) {
                await showInformDialog(context, 'ভুল করছেন',
                    'এই সদস্য নম্বরের একজন সদস্য এরই মাঝে আছেন।');
                return;
              }

              showWaitDialog(context);

              Map<String, String> currentAddress = {
                'village': sanitizeHtml(_villageController.text),
                'post': sanitizeHtml(_postController.text),
                'upazilla': sanitizeHtml(_upazillaController.text),
                'district': sanitizeHtml(_districtController.text),
              };

              phoneNumbers = phoneNumbers
                  .map((phoneNumber) => sanitizeHtml(phoneNumber))
                  .toList();

              Map<String, dynamic> data = {
                'memberID': sanitizeHtml(_memberIDController.text),
                'nameInBanglaLetters':
                    sanitizeHtml(_nameInBanglaLettersController.text),
                'nameInEnglishLetters':
                    sanitizeHtml(_nameInEnglishLettersController.text),
                'bloodGroup': sanitizeHtml(selectedBloodGroup!),
                'lastDonationDate': sanitizeHtml(lastDonationDate),
                'phoneNumbers': phoneNumbers,
                'fbProfileLink': sanitizeHtml(_fbProfileLinkController.text),
                'fatherOrHusbandName':
                    sanitizeHtml(_fatherOrHusbandNameController.text),
                'motherName': sanitizeHtml(_motherNameController.text),
                'birthDate': sanitizeHtml(birthDate!),
                'profession': sanitizeHtml(_professionController.text),
                'currentAddress': currentAddress,
                'addAndModificationDetails': FieldValue.arrayUnion([
                  'Added by ${admin.get('username')} (${admin.get('name')})'
                ]),
              };

              donor.reference.set(data).then((value) async {
                Navigator.of(context).pop();
                await showInformDialog(context, 'সফল',
                    'নতুন রক্তদাতার তথ্য ডাটাবেস সিস্টেমে যুক্ত হয়েছে।');
                _formKey.currentState!.reset();
                return;
              }, onError: (error) async {
                Navigator.of(context).pop();
                await showInformDialog(context, 'দুঃখিত',
                    'নতুন রক্তদাতার তথ্য ডাটাবেস সিস্টেমে যুক্ত হয়নি। ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
                return;
              });
            }, //Button onPressed
          ),
          const SizedBox(
            height: 32.0,
          ),
          Expanded(
            child: ListView(
              children: [
                TextFormField(
                  controller: _memberIDController,
                  decoration: const InputDecoration(
                    labelText: 'ডোনার আইডি',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'ডোনার আইডি লিখেননি।';
                    }
                    _memberIDController.text = value;
                    if (!value.isNumeric()) {
                      return 'ডোনার আইডিতে শুধু ইংরেজি ডিজিট থাকবে।';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nameInBanglaLettersController,
                  decoration: const InputDecoration(
                    labelText: 'বাংলা হরফে নাম',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'বাংলা হরফে নাম লিখেননি।';
                    }
                    _nameInBanglaLettersController.text = value;
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nameInEnglishLettersController,
                  decoration: const InputDecoration(
                    labelText: 'ইংরেজি হরফে নাম',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'ইংরেজি হরফে নাম লিখেননি।';
                    }
                    _nameInEnglishLettersController.text = value;
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'রক্তের গ্রুপ'),
                  items: bloodGroupsList.map((bloodGroup) {
                    return DropdownMenuItem(
                      value: bloodGroup,
                      child: Text(bloodGroup),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedBloodGroup = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'রক্তের গ্রুপ বাছাই করেননি।';
                    }
                    return null;
                  },
                ),
                DateTimePicker(
                  type: DateTimePickerType.date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                  decoration: const InputDecoration(
                    labelText: 'সর্বশেষ রক্তদানের তারিখ',
                    helperText:
                        'আগে কখনো রক্তদান না করে থাকলে এই ঘর খালি রাখুন অথবা, ইচ্ছামত বা সুবিধামত অনেক আগের একটি তারিখ লিখে রাখুন',
                    helperMaxLines: 5,
                  ),
                  onChanged: (value) {
                    lastDonationDate = value;
                  },
                ),
                TextFormField(
                  controller: _phoneNumbersController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ফোন নম্বরসমুহ',
                    helperMaxLines: 5,
                    helperText:
                        'একাধিক ফোন নাম্বার হলে, স্পেস দিয়ে আলাদা করে লিখুন।',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'ফোন নম্বর লিখেননি।';
                    }
                    _phoneNumbersController.text = value;
                    phoneNumbers = _phoneNumbersController.text.split(
                      RegExp(
                        r'\s+',
                        multiLine: true,
                      ),
                    );
                    if (phoneNumbers.isEmpty) {
                      return 'ফোন নম্বর লিখেননি';
                    }
                    _phoneNumbersController.text = phoneNumbers.join(' ');
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fbProfileLinkController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ফেসবুক প্রোফাইলের লিংক',
                    helperMaxLines: 5,
                    helperText: 'ফেসবুক প্রোফাইল না থাকলে খালি রাখুন।',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      if (value != null) {
                        _fbProfileLinkController.text = value;
                      }
                      return null; //Making it Optional
                    }
                    _fbProfileLinkController.text = value;

                    if (!value.isUrl()) {
                      return 'লিংক সঠিক নয়।';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fatherOrHusbandNameController,
                  decoration: const InputDecoration(
                    labelText: 'পিতা বা স্বামীর নাম',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'পিতা বা স্বামীর নাম লিখেননি।'; //Making it Optional
                    }
                    _fatherOrHusbandNameController.text = value;
                    return null;
                  },
                ),
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: 'মাতার নাম',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'মায়ের নাম লিখেননি।'; //Making it Optional
                    }
                    _motherNameController.text = value;
                    return null;
                  },
                ),
                DateTimePicker(
                  type: DateTimePickerType.date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                  decoration: const InputDecoration(
                    labelText: 'জন্ম তারিখ',
                  ),
                  onChanged: (value) {
                    birthDate = value;
                  },
                  validator: (value) {
                    if (value == null || birthDate == null) {
                      return 'জন্মতারিখ লিখেননি।';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _professionController,
                  decoration: const InputDecoration(
                    labelText: 'রক্তদাতার পেশা',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'রক্তদাতার পেশা লিখেননি।'; //Making it Optional
                    }
                    _professionController.text = value;
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                const Center(
                  child: Text(
                    'বর্তমান ঠিকানা',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _villageController,
                  decoration: const InputDecoration(
                    labelText: 'গ্রাম',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'গ্রাম লিখেননি।'; //Making it Optional
                    }
                    _villageController.text = value;
                    return null;
                  },
                ),
                TextFormField(
                  controller: _postController,
                  decoration: const InputDecoration(
                    labelText: 'ডাকঘর/পোস্ট',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'ডাকঘর/পোস্ট লিখেননি।'; //Making it Optional
                    }
                    _postController.text = value;
                    return null;
                  },
                ),
                TextFormField(
                  controller: _upazillaController,
                  decoration: const InputDecoration(
                    labelText: 'উপজেলা',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'উপজেলা লিখেননি।'; //Making it Optional
                    }
                    _upazillaController.text = value;
                    return null;
                  },
                ),
                TextFormField(
                  controller: _districtController,
                  decoration: const InputDecoration(
                    labelText: 'জেলা',
                  ),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'জেলা লিখেননি।'; //Making it Optional
                    }
                    _districtController.text = value;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
