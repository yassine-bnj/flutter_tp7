import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:tp7_test/entities/matiere.dart';

Future getAllmatieres() async {
  Response response =
      await http.get(Uri.parse("http://10.0.2.2:8081/matiere/all"));
  return jsonDecode(response.body);
}

Future deletematiere(int id) {
  return http.delete(Uri.parse("http://10.0.2.2:8081/matiere/delete?id=${id}"));
}

Future addmatiere(Matiere matiere) async {
  Response response =
      await http.post(Uri.parse("http://10.0.2.2:8081/matiere/ajouter"),
          headers: {"Content-type": "Application/json"},
          body: jsonEncode(<String, dynamic>{
            "nomMat": matiere.nomMat,
            "intitule": matiere.intitule,
            "coef": matiere.coef,
            "nbrHs": matiere.nbrHs,
            "classes": matiere.classes!.map((e) => e.toJson()).toList()
          }));

  return response.body;
}

Future updatematieree(Matiere matiere, int id) async {
  print("in the update api call");
  print(matiere.toJson());
  print(id);
  Response response =
      await http.put(Uri.parse("http://10.0.2.2:8081/matiere/modifier/${id}"),
          headers: {"Content-type": "Application/json"},
          body: jsonEncode(<String, dynamic>{
            "codeMat": id,
            "nomMat": matiere.nomMat,
            "intitule": matiere.intitule,
            "code": matiere.codeMat,
            "coef": matiere.coef,
            "nbrHs": matiere.nbrHs,
            "classes": matiere.classes!.map((e) => e.toJson()).toList()
          }));

  return response.body;
}
