import 'dart:convert';
import 'package:demande_mobile/addDemande.dart';
import 'package:demande_mobile/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDemandeDetails {
  final int id;
  final String titre;
  final String description;
  final String comite;
  final String type;
  final String? etat;
  final DateTime dateDebut;
  final DateTime dateFin;

  UserDemandeDetails({
    required this.id,
    required this.titre,
    required this.description,
    required this.comite,
    required this.type,
    this.etat,
    required this.dateDebut,
    required this.dateFin,
  });

  factory UserDemandeDetails.fromJson(Map<String, dynamic> json) {
    return UserDemandeDetails(
      id: json['id'] ?? 0,
      titre: json['titre'],
      description: json['description'],
      comite: json['comite'],
      type: json['type'],
      etat: json['etat'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'comite': comite,
      'type': type,
      'etat': etat,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
            .copyWith(secondary: Colors.orange),
      ),
      home: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<UserListPage> {
  List<dynamic> demandeList = [];
  List<dynamic> filteredDemandeList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> addDemande() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDemandeWidget(
          onDemandeAdded: () {
            fetchData();
          },
        );
      },
    );
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    final response = await http.get(
      Uri.parse('http://192.168.56.1:8060/api/demande/findbyuser/$username'),
    );

    if (response.statusCode == 200) {
      setState(() {
        demandeList = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> deleteDemande(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.56.1:8060/api/demande/delete/$id'),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to delete demande');
      }
    } catch (e) {
      print('Error deleting demande: $e');
    }
  }

  Future<void> showDetailsModal(UserDemandeDetails details) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Details de la Demande'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Titre: ${details.titre}'),
                Text('Description: ${details.description}'),
                Text('Comite: ${details.comite}'),
                Text('Type: ${details.type}'),
                Text('Etat: ${details.etat}'),
                Text('Date de début: ${details.dateDebut}'),
                Text('Date de fin: ${details.dateFin}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this demande?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteDemande(id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateDemande(int id, UserDemandeDetails details) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.56.1:8060/api/demande/update/$id'),
        body: json.encode(details.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to update demande');
      }
    } catch (e) {
      print('Error updating demande: $e');
    }
  }

  void searchDemandes(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, display all items
        filteredDemandeList = List.from(demandeList);
      } else {
        // Otherwise, filter based on the search query
        filteredDemandeList = demandeList
            .where((demande) =>
                demande['titre'].toLowerCase().contains(query.toLowerCase()) ||
                demande['description']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> showEditModal(UserDemandeDetails details) async {
    TextEditingController titreController =
        TextEditingController(text: details.titre);
    TextEditingController descriptionController =
        TextEditingController(text: details.description);
    TextEditingController comiteController =
        TextEditingController(text: details.comite);
    TextEditingController typeController =
        TextEditingController(text: details.type);
    TextEditingController dateDebutController =
        TextEditingController(text: details.dateDebut.toIso8601String());
    TextEditingController dateFinController =
        TextEditingController(text: details.dateFin.toIso8601String());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Demande'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titreController,
                  decoration: InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: comiteController,
                  decoration: InputDecoration(labelText: 'Comite'),
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: dateDebutController,
                  decoration: InputDecoration(labelText: 'Date de début'),
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      dateDebutController.text = date.toIso8601String();
                    }
                  },
                ),
                TextField(
                  controller: dateFinController,
                  decoration: InputDecoration(labelText: 'Date de fin'),
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      dateFinController.text = date.toIso8601String();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                UserDemandeDetails updatedDetails = UserDemandeDetails(
                  id: details.id,
                  titre: titreController.text,
                  description: descriptionController.text,
                  comite: comiteController.text,
                  type: typeController.text,
                  dateDebut: DateTime.parse(dateDebutController.text),
                  dateFin: DateTime.parse(dateFinController.text),
                );

                updateDemande(details.id, updatedDetails);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demande List'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                searchDemandes(query);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search for demandes...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredDemandeList.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredDemandeList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(filteredDemandeList[index]['titre']),
                          subtitle:
                              Text(filteredDemandeList[index]['description']),
                          onTap: () {
                            fetchDetails(filteredDemandeList[index]['id']);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showEditModal(
                                    UserDemandeDetails.fromJson(
                                      filteredDemandeList[index],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  confirmDelete(
                                      filteredDemandeList[index]['id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addDemande,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> fetchDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.56.1:8060/api/demande/id/$id'),
      );

      if (response.statusCode == 200) {
        UserDemandeDetails details =
            UserDemandeDetails.fromJson(json.decode(response.body));
        showDetailsModal(details);
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }
}
