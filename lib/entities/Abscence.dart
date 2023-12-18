import 'dart:ffi';

import 'package:tp7_test/entities/matiere.dart';
import 'package:tp7_test/entities/student.dart';

class Abscence {
  //   private Long id;

  // @ManyToOne
  // private Matiere matiere;

  // @ManyToOne
  // private Etudiant etudiant;

  // private Date date;

  // private int nha;

  Matiere? matiere;
  Student? etudiant;
  String? date;
  double? nha;
  int? id;

  Abscence(this.matiere, this.etudiant, this.date, this.nha, [this.id]);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matiere': matiere!.toJson(),
      'etudiant': etudiant!.toJson(),
      'date': date,
      'nha': nha,
    };
  }

  factory Abscence.fromJson(Map<String, dynamic> json) {
    return Abscence(
      json['id'],
      json['matiere'],
      json['etudiant'],
      json['date'],
      json['nha'],
    );
  }

  @override
  String toString() {
    return 'Abscence{id: $id, matiere: $matiere, etudiant: $etudiant, date: $date, nha: $nha}';
  }
}
