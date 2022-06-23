import '../../../utilities/JSON/my_json_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isSavedAuthenticationTokenValid(DocumentSnapshot serverDocSnap) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authenticationToken = prefs.getString('authenticationToken')!;

  DocumentSnapshot admin = await serverDocSnap.reference.get();

  List<String> authenticationTokens = [];

  try {
    authenticationTokens = getListFromJSONArray(admin.get('authenticationTokens'));
  } catch(error) {
    1;
  }

  return authenticationTokens.contains(authenticationToken);
}