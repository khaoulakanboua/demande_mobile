import 'dart:convert';
import 'package:demande_mobile/addDemande.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
            .copyWith(secondary: Colors.orange), // Set your accent color
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
            // Called when a new demande is successfully added
            fetchData(); // Refresh the list
          },
        );
      },
    );
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://192.168.11.1:8060/api/demande/all'));

    if (response.statusCode == 200) {
      setState(() {
        demandeList = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
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
                // Add other details as needed
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
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: demandeList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: demandeList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(demandeList[index]['titre']),
                    subtitle: Text(demandeList[index]['description']),
                    onTap: () {
                      fetchDetails(demandeList[index]['id']);
                    },
                  ),
                );
              },
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
        Uri.parse('http://192.168.11.1:8060/api/demande/id/$id'),
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
