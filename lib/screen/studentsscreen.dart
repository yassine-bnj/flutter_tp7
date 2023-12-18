import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tp7_test/entities/classe.dart';
import 'package:tp7_test/entities/student.dart';
import 'package:tp7_test/service/classeservice.dart';
import 'package:tp7_test/service/studentservice.dart';
import 'package:tp7_test/template/navbar.dart';

import '../template/dialog/studentdialog.dart';

class StudentScreen extends StatefulWidget {
  Classe? classe;

  StudentScreen({Key? key, this.classe}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  double _currentFontSize = 0;
  String nomClasse = "tous les étudiants";
  List<Classe> classes = [];
  Classe? selectedClass;
  int departementId = 1;
  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.classe != null) {
      print("widget.classe");
      print(widget.classe);
      nomClasse = "étudiants ${widget.classe!.nomClass}";
      //  selectedClass = widget.classe;
    }
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    // departementId = widget.classe!.departement!.code!;
    // print("id : ");
    // print(departementId);

    print(widget.classe?.toJson());
    print("departementId");
    // print(widget.classe!.departement!.code);
    List<dynamic> result = await getAllClasses();
    // List<dynamic> result = await getClassesByDepartementId(departementId);
    setState(() {
      print("get all classes");
      print(result);

      result.forEach((element) {
        classes.add(Classe(
            element['nbreEtud'], element['nomClass'], element['codClass']));
      });
    });
  }

  Future<void> getStudentList() async {
    if (selectedClass != null) {
      return getStudentsByClasseId(selectedClass!.codClass);
    } else if (widget.classe != null) {
      return getStudentsByClasseId(widget.classe!.codClass);
    } else {
      return getAllStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nomClasse),
      ),
      body: Column(
        children: [
          DropdownButton<Classe>(
            hint: const Text("Choisir une classe"),
            value: selectedClass,
            onChanged: (Classe? value) {
              setState(() {
                selectedClass = value;
                nomClasse = "étudiants ${selectedClass!.nomClass}";
                getStudentList();
              });
            },
            items: classes.map((classe) {
              return DropdownMenuItem<Classe>(
                value: classe,
                child: Text(classe.nomClass),
              );
            }).toList(),
          ),
          Expanded(
              child: FutureBuilder(
            future: getStudentList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                return Center(
                  child: Text(
                    "Aucun étudiant trouvé",
                    style: TextStyle(fontSize: 20),
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Slidable(
                      key: Key((snapshot.data[index]['id']).toString()),
                      startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              AlertDialog alert = AlertDialog(
                                title: Text("Supprimer"),
                                content: Text(
                                    "Voulez-vous supprimer cet étudiant ?"),
                                actions: [
                                  TextButton(
                                    child: Text("Oui"),
                                    onPressed: () async {
                                      await deleteStudent(
                                          snapshot.data[index]['id']);
                                      setState(() {
                                        snapshot.data.removeAt(index);
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Non"),
                                    onPressed: () {
                                      BuildContext dialogContext = context;
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            },
                            backgroundColor: Color.fromARGB(255, 202, 33, 33),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'delete',
                            spacing: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text("Nom et Prénom :" +
                                snapshot.data[index]['nom'] +
                                " " +
                                snapshot.data[index]['prenom']),
                            subtitle: Text(
                              'Date de Naissance :' +
                                  DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(
                                          snapshot.data[index]['dateNais'])),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              alignment: Alignment.centerRight,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddStudentDialog(
                                          notifyParent: refresh,
                                          student: Student(
                                            snapshot.data[index]['dateNais'],
                                            snapshot.data[index]['nom'],
                                            snapshot.data[index]['prenom'],
                                            Classe(
                                              snapshot.data[index]['classe']
                                                  ['nbreEtud'],
                                              snapshot.data[index]['classe']
                                                  ['nomClass'],
                                              snapshot.data[index]['classe']
                                                  ['codClass'],
                                            ),
                                            snapshot.data[index]['id'],
                                          ));
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddStudentDialog(
                  notifyParent: refresh,
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
