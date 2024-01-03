import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8060/api/demande/save'),
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
        }),
      );

      if (response.statusCode == 200) {
        // Successfully added the demande
        // Notify the parent widget about the ajout
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
      title: Text('Ajouter une demande'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: titreController,
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: comiteController,
              decoration: InputDecoration(labelText: 'Comite'),
            ),
            TextFormField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
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
                  decoration: InputDecoration(labelText: 'Date de début'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectDateFin(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text:
                        dateFinController?.toLocal().toString().split(' ')[0] ??
                            '',
                  ),
                  decoration: InputDecoration(labelText: 'Date de fin'),
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
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            await addDemande();
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}
