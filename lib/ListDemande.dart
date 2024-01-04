import 'dart:convert';
import 'package:demande_mobile/addDemande.dart';
import 'package:demande_mobile/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class DemandeDetails {
  final String titre;
  final String description;
  final String comite;
  final String type;
  final String etat;
  final DateTime dateDebut;
  final DateTime dateFin;

  DemandeDetails({
    required this.titre,
    required this.description,
    required this.comite,
    required this.type,
    required this.etat,
    required this.dateDebut,
    required this.dateFin,
  });

  factory DemandeDetails.fromJson(Map<String, dynamic> json) {
    return DemandeDetails(
      titre: json['titre'],
      description: json['description'],
      comite: json['comite'],
      type: json['type'],
      etat: json['etat'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
    );
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    final response =
        await http.get(Uri.parse('http://192.168.56.1:8060/api/demande/all'));

    if (response.statusCode == 200) {
      setState(() {
        demandeList = json.decode(response.body);
        filteredDemandeList = List.from(demandeList);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void searchDemandes(String query) {
    setState(() {
      filteredDemandeList = demandeList
          .where((demande) =>
              demande['titre'].toLowerCase().contains(query.toLowerCase()) ||
              demande['description']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> showDetailsModal(DemandeDetails details) async {
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
              controller: searchController,
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
            child: demandeList.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredDemandeList.length,
                    itemBuilder: (context, index) {
                      String etat = filteredDemandeList[index]['etat'];
                      Color acceptButtonColor =
                          etat == 'rejected' ? Colors.grey : Colors.green;
                      Color rejectButtonColor =
                          etat == 'accepted' ? Colors.grey : Colors.red;

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(filteredDemandeList[index]['titre']),
                          subtitle: Text(
                            filteredDemandeList[index]['etat'],
                            style: TextStyle(
                              color: etat == 'rejected'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          trailing: etat == 'rejected' || etat == 'accepted'
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        acceptDemande(
                                            filteredDemandeList[index]['id']);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          acceptButtonColor,
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                      child: Text('Accepter'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        rejectDemande(
                                            filteredDemandeList[index]['id']);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          rejectButtonColor,
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                      child: Text('Rejeter'),
                                    ),
                                  ],
                                ),
                          onTap: () {
                            fetchDetails(filteredDemandeList[index]['id']);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> acceptDemande(int id) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.56.1:8060/api/demande/accept/$id'),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to accept demande');
      }
    } catch (e) {
      print('Error accepting demande: $e');
    }
  }

  Future<void> rejectDemande(int id) async {
    try {
      final response = await http.put(
        Uri.parse('http:/192.168.56.1:8060/api/demande/reject/$id'),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to reject demande');
      }
    } catch (e) {
      print('Error rejecting demande: $e');
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

  Future<void> fetchDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.56.1:8060/api/demande/id/$id'),
      );

      if (response.statusCode == 200) {
        DemandeDetails details =
            DemandeDetails.fromJson(json.decode(response.body));
        showDetailsModal(details);
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }
}
