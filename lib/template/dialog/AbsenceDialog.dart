import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tp7_test/entities/Abscence.dart';
import 'package:tp7_test/entities/matiere.dart';
import 'package:tp7_test/entities/student.dart';
import 'package:tp7_test/service/abscenceService.dart';
import 'package:tp7_test/service/matiereservice.dart';

class AbsenceDialog extends StatefulWidget {
  final Function()? notifyParent;
  List<Matiere> matieres = [];
  Student? student;
  Abscence? selectedAbsence;
  Matiere selectedMatiere = Matiere();
  AbsenceDialog({
    Key? key,
    @required this.notifyParent,
    this.student,
    this.selectedAbsence,
  }) : super(key: key);

  @override
  State<AbsenceDialog> createState() => _AbsenceDialogState();
}

class _AbsenceDialogState extends State<AbsenceDialog> {
  DateTime selectedDate = DateTime.now();
  TextEditingController numericValueController = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  String title = "Ajouter abscence";
  String action = "Ajouter";

  @override
  void initState() {
    super.initState();
    // Initialize controllers and variables
    fetchMatieres();
    // if (widget.matiere != null) {
    //   modif = true;
    //   title = "Modifier Matiere";
    //   action = "Modifier";
    //   nomCtrl.text = widget.matiere!.nomMat!;
    //   coefCtrl.text = widget.matiere!.coef!.toString();
    //   nbHsCtrl.text = widget.matiere!.nbrHs!.toString();
    //   // Set selected classes based on the existing Matiere
    //   selectedClasses = widget.matiere!.classes ?? [];
    //   // Set intitule based on the existing Matiere
    //   intituleCtrl.text = widget.matiere!.intitule ?? "";
    // }
    // Pre-fill the form fields with initial values for editing
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        dateCtrl.text =
            DateFormat("yyyy-MM-dd").format(DateTime.parse(picked.toString()));
        selectedDate = picked;
      });
    }
  }

  Future<void> fetchMatieres() async {
    try {
      List<dynamic> matList = await getAllmatieres();

      List<Matiere> listeMatieres = [];

      matList.forEach((element) {
        Matiere matiere = Matiere(
          codeMat: element['codeMat'],
          nomMat: element['nomMat'],
          intitule: element['intitule'],
          nbrHs: element['classeMatieres'][0]['nbrHs'],
          coef: element['classeMatieres'][0]['coef'],
        );
        listeMatieres.add(matiere);
      });

      setState(() {
        widget.matieres = listeMatieres;
        if (widget.selectedAbsence != null) {
          print(widget.selectedAbsence!.toJson());
          title = "Modifier abscence";
          action = "Modifier";

          Matiere matiere = widget.selectedAbsence!.matiere!;
          widget.selectedMatiere = matiere;
          print("selected mat");
          print(widget.selectedMatiere!.toJson());
          for (var i = 0; i < widget.matieres.length; i++) {
            if (widget.matieres[i].codeMat == matiere.codeMat) {
              widget.selectedMatiere = widget.matieres[i];
            }
          }
          numericValueController.text = widget.selectedAbsence!.nha.toString();
          dateCtrl.text = widget.selectedAbsence!.date!;
          selectedDate = DateTime.parse(widget.selectedAbsence!.date!);
        } else {
          widget.selectedMatiere = widget.matieres[0];
        }
      });
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  Future<void> addOrUpdateAbsence() async {
    Abscence absence = Abscence(
      widget.selectedMatiere,
      this.widget.student!,
      dateCtrl.text,
      double.parse(numericValueController.text),
    );

    try {
      if (widget.selectedAbsence != null) {
        // If selectedAbsence is provided, update the existing absence
        await updateAbscence(absence, widget.selectedAbsence!.id!);
      } else {
        // If selectedAbsence is not provided, add a new absence
        await addAbscence(absence);
      }

      // Notify the parent and close the dialog
      widget.notifyParent!();
      Navigator.pop(context);
    } catch (e) {
      print('Error adding/editing absence: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              Text(title),
              DropdownButtonFormField<Matiere>(
                hint: const Text("Selectionner une matiere"),
                value: widget.selectedMatiere,
                onChanged: (Matiere? value) {
                  setState(() {
                    widget.selectedMatiere = value!;
                  });
                },
                items: widget.matieres.map((matiere) {
                  return DropdownMenuItem<Matiere>(
                    value: matiere,
                    child: Text(matiere.nomMat!),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: "Matiere"),
                validator: (value) {
                  if (value == null) {
                    return 'S il vous plaît sélectionner une matière';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: numericValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nha"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a numeric value.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date d'absence"),
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  addOrUpdateAbsence();
                },
                child: Text(action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
