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
  TextEditingController searchController = TextEditingController();

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
      Uri.parse('http://192.168.1.2:8060/api/demande/findbyuser/$username'),
    );

    if (response.statusCode == 200) {
      setState(() {
        demandeList = (json.decode(response.body) as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
        print("Demande List: $demandeList");
        filteredDemandeList = List.from(demandeList);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> deleteDemande(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.2:8060/api/demande/delete/$id'),
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
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Détails de la Demande',
                style: TextStyle(color: Colors.blue),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Titre', details.titre, Icons.title, Colors.blue),
              _buildDetailRow('Description', details.description, Icons.description, Colors.blue),
              _buildDetailRow('Comite', details.comite, Icons.people, Colors.blue),
              _buildDetailRow('Type', details.type, Icons.category, Colors.blue),
              _buildDetailRow('Etat', details.etat ?? 'N/A', Icons.check_circle, _getStatusColor(details.etat)),
              _buildDetailRow('Date de début', _formatDate(details.dateDebut), Icons.date_range, Colors.blue),
              _buildDetailRow('Date de fin', _formatDate(details.dateFin), Icons.date_range, Colors.blue),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fermer', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}


  Widget _buildDetailRow(
      String label, String value, IconData icon, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(value, style: TextStyle(color: textColor)),
                Divider(
                    color:
                        textColor), // Add a line separator for better visibility
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'inprogress':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  Future<void> confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this demande?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteDemande(id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateDemande(int id, UserDemandeDetails details) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.2:8060/api/demande/update/$id'),
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
    print("Original Demande List: $demandeList");
    setState(() {
      if (query.isEmpty) {
        filteredDemandeList = List.from(demandeList);
      } else {
        filteredDemandeList = demandeList
            .where((demande) =>
                demande['titre'].toLowerCase().contains(query.toLowerCase()) ||
                demande['description']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }

      print("Filtered Demande List: $filteredDemandeList");

      if (filteredDemandeList.isEmpty) {
        filteredDemandeList = [];
        print("List is cleared");
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
        TextEditingController(text: _formatDate(details.dateDebut));
    TextEditingController dateFinController =
        TextEditingController(text: _formatDate(details.dateFin));

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Demande',
              style: TextStyle(color: Colors.indigo)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titreController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    icon: Icon(Icons.title, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.description, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: comiteController,
                  decoration: const InputDecoration(
                    labelText: 'Comite',
                    icon: Icon(Icons.people, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    icon: Icon(Icons.category, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDateDebut(context, dateDebutController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: dateDebutController,
                      decoration: const InputDecoration(
                        labelText: 'Date de début',
                        icon: Icon(Icons.date_range, color: Colors.indigo),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDateFin(context, dateFinController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: dateFinController,
                      decoration: const InputDecoration(
                        labelText: 'Date de fin',
                        icon: Icon(Icons.date_range, color: Colors.indigo),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child:
                  const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateDebut(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final formattedDate = _formatDate(picked);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> _selectDateFin(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final formattedDate = _formatDate(picked);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Widget getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Icon(Icons.verified, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.clear, color: Colors.red);
      case 'inprogress':
        return const Icon(Icons.timer, color: Colors.orange);
      default:
        return const Icon(Icons.help);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande List'),
        backgroundColor: const Color(0xFF54408C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                searchDemandes(query);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search for demandes...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: demandeList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredDemandeList.length,
                    itemBuilder: (context, index) {
                      final displayedDemande = filteredDemandeList[index];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            displayedDemande['titre'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayedDemande['description']),
                              const SizedBox(height: 8),
                              Text(
                                'Comite: ${displayedDemande['comite']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Type: ${displayedDemande['type']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Etat: ${displayedDemande['etat'] ?? 'N/A'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  getStatusIcon(displayedDemande['etat'] ?? ''),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            fetchDetails(displayedDemande['id']);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.green,
                                onPressed: () {
                                  showEditModal(
                                    UserDemandeDetails.fromJson(
                                        displayedDemande),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  confirmDelete(displayedDemande['id']);
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
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Future<void> fetchDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8060/api/demande/id/$id'),
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
