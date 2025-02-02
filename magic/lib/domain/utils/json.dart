import 'dart:convert';
import 'dart:io';

Future<List<Map>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map['users'];
}
