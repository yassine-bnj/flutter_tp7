import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:tp7_test/entities/Abscence.dart';

// get abscences by student id

Future getAbscencesByStudentId(int? id) async {
  Response response = await http
      .get(Uri.parse("http://10.0.2.2:8081/abscence/findByStudentId/${id}"));

  return jsonDecode(response.body);
}

//delete
Future deleteAbscence(int id) {
  return http.delete(Uri.parse("http://10.0.2.2:8081/abscence/delete/${id}"));
}

//add
Future addAbscence(Abscence ab) async {
  Response response =
      await http.post(Uri.parse("http://10.0.2.2:8081/abscence/add"),
          headers: {"Content-type": "Application/json"},
          body: jsonEncode(<String, dynamic>{
            "date": ab.date,
            "nha": ab.nha,
            "etudiant": ab.etudiant!.toJson(),
            "matiere": ab.matiere!.toJson(),
          }));

  return response.body;
}

Future updateAbscence(Abscence ab, int id) async {
  print("update abscence");
  print(ab.toJson());
  Response response =
      await http.put(Uri.parse("http://10.0.2.2:8081/abscence/update/${id}"),
          headers: {"Content-type": "Application/json"},
          body: jsonEncode(<String, dynamic>{
            "id": id,
            "date": ab.date,
            "nha": ab.nha,
            "etudiant": ab.etudiant!.toJson(),
            "matiere": ab.matiere!.toJson(),
          }));

  return response.body;
}
