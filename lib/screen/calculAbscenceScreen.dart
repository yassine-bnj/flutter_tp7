import 'package:flutter/material.dart';
import 'package:tp7_test/entities/Abscence.dart';
import 'package:tp7_test/entities/classe.dart';
import 'package:tp7_test/entities/matiere.dart';
import 'package:tp7_test/entities/student.dart';
import 'package:tp7_test/service/abscenceService.dart';
import 'package:tp7_test/service/studentservice.dart';
import 'package:tp7_test/template/dialog/AbsenceDialog.dart';

class CalculAbscenceScreen extends StatefulWidget {
  CalculAbscenceScreen();

  @override
  _CalculAbscenceScreenState createState() => _CalculAbscenceScreenState();
}

class _CalculAbscenceScreenState extends State<CalculAbscenceScreen> {
  Student? selectedStudent;
  late List<Student> students = [];

  List<dynamic> absences = [];
  Map<String, List<dynamic>> groupedAbsences = {};

  @override
  void initState() {
    super.initState();
    // Fetch the list of students
    fetchStudents();
  }

  refresh() {
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

  void onStudentSelected(Student? student) {
    setState(() {
      selectedStudent = student;
      groupedAbsences =
          {}; // Reset the groupedAbsences when a new student is selected
      if (selectedStudent != null) {
        fetchAbsencesByStudentId(selectedStudent!.id!);
      }
    });
  }

  Future<void> fetchAbsencesByStudentId(int studentId) async {
    try {
      List<dynamic> absencesList = await getAbscencesByStudentId(studentId);
      print('absencesList: $absencesList');

      // Group absences by matiere
      groupedAbsences = groupAbsencesByMatiere(absencesList);

      setState(() {
        absences = absencesList;
      });
    } catch (e) {
      print('Error fetching absences: $e');
    }
  }

  Map<String, List<dynamic>> groupAbsencesByMatiere(
      List<dynamic> absencesList) {
    Map<String, List<dynamic>> groupedAbsences = {};

    for (var absence in absencesList) {
      Matiere matiere = Matiere(
        nomMat: absence['matiere']['nomMat'],
        intitule: absence['matiere']['intitule'],
        codeMat: absence['matiere']['codeMat'],
        nbrHs: absence['matiere']['nbrHs'],
        coef: absence['matiere']['coef'],
      );

      String matiereKey = matiere.codeMat.toString();

      groupedAbsences.putIfAbsent(matiereKey, () => []);
      groupedAbsences[matiereKey]!.add(absence);
    }

    return groupedAbsences;
  }

  double calculateTotalAbsences(List<dynamic> matiereAbsences) {
    double totalAbsences = 0;
    for (var absence in matiereAbsences) {
      totalAbsences += (absence['nha'] as double);
    }
    return totalAbsences;
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
          if (groupedAbsences.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: groupedAbsences.length,
                itemBuilder: (context, index) {
                  String matiereKey = groupedAbsences.keys.elementAt(index);
                  List<dynamic> matiereAbsences = groupedAbsences[matiereKey]!;

                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Matiere: ${matiereAbsences.first['matiere']['nomMat']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: matiereAbsences.length,
                          itemBuilder: (context, index) {
                            // Build your ListTile for each absence
                            // matiereAbsences[index] is the absence data
                            return ListTile(
                              title: Text(
                                  'Date: ${matiereAbsences[index]['date']}'),
                              subtitle: Text(
                                  'nbheure: ${matiereAbsences[index]['nha']}'),
                              // ... other details as needed
                            );
                          },
                        ),
                        // Afficher le total des absences pour cette matière
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Total Absences: ${calculateTotalAbsences(matiereAbsences)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          // Afficher le total général des absences pour l'étudiant
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total des abscences: ${calculateTotalGeneralAbsences()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calculer le total général des absences pour l'étudiant
  double calculateTotalGeneralAbsences() {
    double totalGeneralAbsences = 0;
    for (var matiereKey in groupedAbsences.keys) {
      totalGeneralAbsences +=
          calculateTotalAbsences(groupedAbsences[matiereKey]!);
    }
    return totalGeneralAbsences;
  }
}
