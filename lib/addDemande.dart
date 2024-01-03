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
  TextEditingController etatController = TextEditingController();
  TextEditingController dateDebutController = TextEditingController();
  TextEditingController dateFinController = TextEditingController();

  Future<void> addDemande() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.8.195:8060/api/demande/save'),
        body: {
          'titre': titreController.text,
          'description': descriptionController.text,
          'comite': comiteController.text,
          'type': typeController.text,
          'etat': etatController.text,
          'date_debut': dateDebutController.text,
          'date_fin': dateFinController.text,
        },
      );

      if (response.statusCode == 200) {
        // Successfully added the demande
        // Notify the parent widget about the ajout
        widget.onDemandeAdded();
      } else {
        throw Exception('Failed to add demande');
      }
    } catch (e) {
      print('Error adding demande: $e');
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
            TextFormField(
              controller: etatController,
              decoration: InputDecoration(labelText: 'Etat'),
            ),
            TextFormField(
              controller: dateDebutController,
              decoration: InputDecoration(labelText: 'Date de début'),
            ),
            TextFormField(
              controller: dateFinController,
              decoration: InputDecoration(labelText: 'Date de fin'),
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
