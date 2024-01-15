import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddDemandeWidget extends StatefulWidget {
  final Function onDemandeAdded;

  AddDemandeWidget({required this.onDemandeAdded});

  @override
  _AddDemandeWidgetState createState() => _AddDemandeWidgetState();
}

class _AddDemandeWidgetState extends State<AddDemandeWidget> {
  TextEditingController titreController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController comiteController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  DateTime? dateDebutController;
  DateTime? dateFinController;

  Future<void> addDemande() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');
      final response = await http.post(
        Uri.parse('http://192.168.56.1:8060/api/demande/save'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'titre': titreController.text,
          'description': descriptionController.text,
          'comite': comiteController.text,
          'type': typeController.text,
          'date_debut': dateDebutController?.toIso8601String(),
          'date_fin': dateFinController?.toIso8601String(),
          'user': {
            'id': userId,
          },
        }),
      );

      if (response.statusCode == 200) {
        widget.onDemandeAdded();
      } else {
        print('Failed to add demande. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to add demande');
      }
    } catch (e) {
      print('Error adding demande: $e');
    }
  }

  Future<void> _selectDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != dateDebutController) {
      setState(() {
        dateDebutController = picked;
      });
    }
  }

  Future<void> _selectDateFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != dateFinController) {
      setState(() {
        dateFinController = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une demande',
          style: TextStyle(color: Colors.indigo)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: titreController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                icon: Icon(Icons.title, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                icon: Icon(Icons.description, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: comiteController,
              decoration: const InputDecoration(
                labelText: 'Comite',
                icon: Icon(Icons.people, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                icon: Icon(Icons.category, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDateDebut(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: dateDebutController
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Date de début',
                    icon: Icon(Icons.date_range, color: Colors.indigo),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDateFin(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text:
                        dateFinController?.toLocal().toString().split(' ')[0] ??
                            '',
                  ),
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
          child: const Text('Annuler', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () async {
            await addDemande();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(primary: Colors.green),
          child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
