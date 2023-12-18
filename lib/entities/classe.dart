import 'package:tp7_test/entities/departement.dart';

class Classe {
  int nbreEtud;
  String nomClass;
  Departement? departement;
  int? codClass;

  Classe(this.nbreEtud, this.nomClass, [this.codClass]);
  // Classe(this.nbreEtud, this.nomClass, this.departement, [this.codClass]);
  setDepartement(Departement departement) {
    this.departement = departement;
  }

  Map<String, dynamic> toJson() {
    return {
      'codClass': codClass,
      'nomClass': nomClass,
      'nbreEtud': nbreEtud,
      'departement': departement?.toJson(),
    };
  }
}
