import 'package:tp7_test/entities/classe.dart';

class Matiere {
  String? nomMat, intitule;
  int? codeMat, nbrHs, coef;
  //liste des classes
  List<Classe>? classes;

  Matiere({this.nomMat, this.intitule, this.codeMat, this.nbrHs, this.coef});

//set classes
  setClasses(List<Classe> classes) {
    this.classes = classes;
  }

  Map<String, dynamic> toJson() {
    return {
      'nomMat': nomMat,
      'codeMat': codeMat,
      'coef': coef,
      'intitule': intitule,
      'nbrHs': nbrHs,
      //  'classes': classes!.map((e) => e.toJson()).toList()
    };
  }
}
