import 'dart:convert';
import 'package:crypto/crypto.dart';

String getSHA256Hash(String data) {
  return sha256.convert(utf8.encode(data)).toString();
}