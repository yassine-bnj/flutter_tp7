// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:tp7_test/entities/classe.dart';
import 'package:tp7_test/entities/matiere.dart';
import 'package:tp7_test/service/matiereservice.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MatiereDialog extends StatefulWidget {
  final Function()? notifyParent;
  Matiere? matiere;

  // List of available classes for the dropdown
  List<Classe> availableClasses;

  // List of classes coming from the database
  List<Classe> selectedClasses = [];
  Matiere? selectedMatiere;
  MatiereDialog({
    Key? key,
    @required this.notifyParent,
    this.matiere,
    required this.availableClasses,
    required this.selectedClasses,
    this.selectedMatiere,
  }) : super(key: key);

  @override
  _MatiereDialogState createState() => _MatiereDialogState();
}

class _MatiereDialogState extends State<MatiereDialog> {
  TextEditingController nomCtrl = TextEditingController();
  TextEditingController coefCtrl = TextEditingController();
  TextEditingController nbHsCtrl = TextEditingController();
  TextEditingController intituleCtrl =
      TextEditingController(); // New controller

  String title = "Ajouter Matiere";
  String action = "Ajouter";
  bool modif = false;

  // List to store selected classes
  List<Classe> selectedClasses = [];

  @override
  void initState() {
    super.initState();

    if (widget.matiere != null) {
      modif = true;
      title = "Modifier Matiere";
      action = "Modifier";
      nomCtrl.text = widget.matiere!.nomMat!;
      coefCtrl.text = widget.matiere!.coef!.toString();
      nbHsCtrl.text = widget.matiere!.nbrHs!.toString();
      // Set selected classes based on the existing Matiere
      for (var c in widget.availableClasses) {
        for (var classe in widget.matiere!.classes!) {
          if (classe.codClass == c.codClass) {
            selectedClasses.add(c);
          }
        }
      }

      // Set intitule based on the existing Matiere
      intituleCtrl.text = widget.matiere!.intitule ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(title),
            TextFormField(
              controller: nomCtrl,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "Champ obligatoire";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextFormField(
              controller: coefCtrl,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "Champ obligatoire";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "Coefficient"),
            ),
            TextFormField(
              controller: nbHsCtrl,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "Champ obligatoire";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "Nombre d'heures"),
            ),
            // Add TextFormField for intitule
            TextFormField(
              controller: intituleCtrl,
              decoration: const InputDecoration(labelText: "Intitule"),
            ),
            MultiSelectDialogField(
              initialValue: selectedClasses,
              items: widget.availableClasses
                  .map((classe) => MultiSelectItem(classe, classe.nomClass!))
                  .toList(),
              listType: MultiSelectListType.CHIP,
              onConfirm: (List<dynamic> values) {
                // Handle the selected items
                setState(() {
                  // Update the selected classes
                  selectedClasses = values.cast<Classe>();
                });
              },
            ),

            ElevatedButton(
              onPressed: () async {
                if (modif == false) {
                  Matiere matiere = Matiere(
                    nomMat: nomCtrl.text,
                    coef: int.parse(coefCtrl.text),
                    nbrHs: int.parse(nbHsCtrl.text),
                    intitule: intituleCtrl.text, // Use intituleCtrl.text
                  );
                  matiere.setClasses(selectedClasses);
                  print(matiere.toJson());
                  // Call the function to add a new Matiere
                  await addmatiere(matiere);

                  Navigator.of(context).pop();
                  widget.notifyParent!();
                } else {
                  Matiere matiere = Matiere(
                    nomMat: nomCtrl.text,
                    coef: int.parse(coefCtrl.text),
                    nbrHs: int.parse(nbHsCtrl.text),
                    intitule: intituleCtrl.text, // Use intituleCtrl.text
                  );
                  matiere.setClasses(selectedClasses);
                  print(matiere.toJson());
                  // Call the function to add a new Matiere
                  print("matiere is");
                  print(widget.matiere!.toJson());
                  await updatematieree(matiere, widget.matiere!.codeMat!);

                  Navigator.of(context).pop();
                  widget.notifyParent!();
                }
              },
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
