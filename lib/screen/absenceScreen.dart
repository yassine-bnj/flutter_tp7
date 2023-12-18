import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tp7_test/entities/Abscence.dart';
import 'package:tp7_test/entities/classe.dart';
import 'package:tp7_test/entities/matiere.dart';
import 'package:tp7_test/entities/student.dart';
import 'package:tp7_test/service/abscenceService.dart';
import 'package:tp7_test/service/studentservice.dart';
import 'package:tp7_test/template/dialog/AbsenceDialog.dart';

class AbsenceScreen extends StatefulWidget {
  AbsenceScreen();

  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  Student? selectedStudent;
  late List<Student> students = [];

  List<dynamic> absences = []; // Add this list for storing absences

  @override
  void initState() {
    super.initState();
    // Fetch the list of students
    fetchStudents();
  }

  refresh() {
    fetchAbsencesByStudentId(selectedStudent!.id!);
    setState(() {});
  }

  Future<void> fetchStudents() async {
    try {
      List<dynamic> studentList = await getAllStudent();

      List<Student> studentss = [];
      studentList.forEach((element) {
        Classe c = Classe(
          element['classe']['nbreEtud'],
          element['classe']['nomClass'],
          element['classe']['codClass'],
        );
        Student student = Student(
          element['dateNais'],
          element['nom'],
          element['prenom'],
          c,
          element['id'],
        );
        studentss.add(student);
      });

      setState(() {
        students = studentss;
      });
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<void> fetchAbsencesByStudentId(int studentId) async {
    try {
      List<dynamic> absencesList = await getAbscencesByStudentId(studentId);
      print('absencesList: $absencesList');
      setState(() {
        absences = absencesList;
      });
    } catch (e) {
      print('Error fetching absences: $e');
    }
  }

  void onStudentSelected(Student? student) {
    setState(() {
      selectedStudent = student;
      if (selectedStudent != null) {
        fetchAbsencesByStudentId(selectedStudent!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absences for'),
      ),
      body: Column(
        children: [
          DropdownButton<Student>(
            hint: Text('Select a student'),
            value: selectedStudent,
            onChanged: onStudentSelected,
            items: students
                .map((student) => DropdownMenuItem<Student>(
                      value: student,
                      child: Text('${student.nom} ${student.prenom}'),
                    ))
                .toList(),
          ),
          if (selectedStudent != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Nom: ${selectedStudent!.nom} '),
                  Text('Prenom: ${selectedStudent!.prenom}'),
                  if (selectedStudent!.classe != null)
                    Text('Class: ${selectedStudent!.classe!.nomClass}'),
                  // Add more widgets to display additional information about the student
                ],
              ),
            ),
          if (absences.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: absences.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(absences[index]['id'].toString()),
                    onDismissed: (direction) async {
                      // Implement the logic to delete the item from your data source
                      int deletedId = absences[index]['id'];
                      await deleteAbscence(deletedId);

                      // Update the UI by removing the dismissed item
                      setState(() {
                        absences.removeAt(index);
                      });

                      // Show a snackbar to indicate that the item has been deleted
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Absence deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Implement undo logic if needed
                              // For example, you can add the item back to the list
                              setState(() {
                                absences.insert(index, absences[index]);
                              });
                            },
                          ),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Date: ${absences[index]['date']}'),
                        subtitle: Text(
                          'matiere: ${absences[index]['matiere']['nomMat']}' +
                              "     "
                                  'nbheure: ${absences[index]['nha']}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Handle edit action here
                            // You can open a dialog or navigate to another screen for editing
                            // For example, you can use showDialog to open an edit dialog:
                            //  print(absences[index]['matiere']);

                            Map<String, dynamic> matiereData =
                                absences[index]['matiere'];
                            Matiere matiere = Matiere(
                              nomMat: matiereData['nomMat'],
                              intitule: matiereData['intitule'],
                              codeMat: matiereData['codeMat'],
                              nbrHs: matiereData['nbrHs'],
                              coef: matiereData['coef'],
                            );

                            double nha = absences[index]['nha'];

                            print(absences[index]['id']);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AbsenceDialog(
                                  // Pass the necessary parameters for editing
                                  notifyParent: refresh,
                                  student: selectedStudent,
                                  selectedAbsence: Abscence(
                                    matiere,
                                    selectedStudent!,
                                    absences[index]['date'],
                                    nha,
                                    absences[index]['id'],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // Add more details or widgets as needed
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AbsenceDialog(
                notifyParent: refresh,
                student: selectedStudent,
              );
            },
          );
          //print("test");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
