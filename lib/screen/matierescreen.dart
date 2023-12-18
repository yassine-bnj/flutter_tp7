// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tp7_test/entities/matiere.dart';
import 'package:tp7_test/entities/classe.dart';
import 'package:tp7_test/screen/studentsscreen.dart';
import 'package:tp7_test/service/classeservice.dart';
import 'package:tp7_test/service/matiereservice.dart';
import 'package:tp7_test/template/dialog/matieredialog.dart';
import 'package:tp7_test/template/navbar.dart';

class MatiereScreen extends StatefulWidget {
  @override
  _MatiereScreenState createState() => _MatiereScreenState();
}

class _MatiereScreenState extends State<MatiereScreen> {
  List<Matiere> matieres = [];

  @override
  void initState() {
    super.initState();
    getAllMatieres();
  }

  Future<void> getAllMatieres() async {
    List<dynamic> result = await getAllmatieres();
    setState(() {
      print("get all matieres");
      print(result);
      // Clear existing matieres list
      matieres.clear();
      result.forEach((element) {
        List<dynamic> classeMatieres = element['classeMatieres'];

        // Check if classeMatieres is not empty
        if (classeMatieres.isNotEmpty) {
          // Create a list to store associated classes
          List<Classe> associatedClasses = [];

          // Iterate through classeMatieres and extract class information
          classeMatieres.forEach((classeMatiere) {
            // Extract class details
            Map<String, dynamic> classeDetails = classeMatiere['classe'];
            Classe classe = Classe(
              classeDetails['nbreEtud'],
              classeDetails['nomClass'],
              classeDetails['codClass'],
            );

            // Add the class to the list
            associatedClasses.add(classe);
          });

          // Create a Matiere object with associated classes
          Matiere matiere = Matiere(
            nomMat: element['nomMat'],
            intitule: element['intitule'],
            codeMat: element['codeMat'],
            nbrHs: classeMatieres[0]['nbrHs'],
            coef: classeMatieres[0]['coef'],
          );
          matiere.setClasses(associatedClasses);
          matieres.add(matiere);
        }
        print(matieres);
      });
    });
  }

  Future<List<Classe>> getAllClassses() async {
    List<dynamic> result = await getAllClasses();
    List<Classe> classes = [];

    result.forEach((element) {
      //Classe(this.nbreEtud, this.nomClass, [this.codClass]);
      classes.add(Classe(
          element['nbreEtud'], element['nomClass'], element['codClass']));
    });

    return classes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('matieres'),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.value(matieres),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(
                    child: Text(
                      "Aucune matiere trouvée",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Slidable(
                        key: Key((snapshot.data[index].codeMat).toString()),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                List<Classe> classesList =
                                    await getAllClassses();
                                Matiere matiere = Matiere(
                                  nomMat: snapshot.data[index].nomMat,
                                  intitule: snapshot.data[index].intitule,
                                  codeMat: snapshot.data[index].codeMat,
                                  nbrHs: snapshot.data[index].nbrHs,
                                  coef: snapshot.data[index].coef,
                                );

                                print(matiere.toJson());

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MatiereDialog(
                                      notifyParent: getAllMatieres,
                                      availableClasses: classesList,
                                      selectedClasses: [],
                                      matiere: snapshot.data[index],
                                    );
                                  },
                                );
                              },
                              backgroundColor: Color(0xFF21B7CA),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          dismissible: DismissiblePane(onDismissed: () async {
                            await deletematiere(
                                snapshot.data[index]['codeMat']);
                            setState(() {
                              snapshot.data.removeAt(index);
                            });
                          }),
                          children: [Container()],
                        ),
                        child: InkWell(
                          onTap: () {
                            // Add logic to navigate or perform actions
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Matiere : "),
                                        Text(
                                          snapshot.data[index].nomMat ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 2.0,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "coef : ${snapshot.data[index].coef}",
                                    ),
                                    Text(
                                      "intitule : ${snapshot.data[index].intitule}",
                                    ),
                                    if ((snapshot.data[index].classes)
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8.0),
                                      const Text("Classes:"),
                                      for (Classe classe
                                          in snapshot.data[index].classes)
                                        Text(
                                          "- ${classe.nomClass}",
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: const CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          List<Classe> classesList = await getAllClassses();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MatiereDialog(
                notifyParent: getAllMatieres,
                availableClasses: classesList,
                selectedClasses: [],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
