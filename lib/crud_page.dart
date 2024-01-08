import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:lab_project/view_student.dart';

class FirestoreCRUDPage extends StatefulWidget {
  const FirestoreCRUDPage({Key? key}) : super(key: key);

  @override
  _FirestoreCRUDPageState createState() => _FirestoreCRUDPageState();
}

class _FirestoreCRUDPageState extends State<FirestoreCRUDPage> {
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('student');

  String newName = '';
  String documentID = ''; // Added field for document ID

  // Generate a random document ID
  String generateRandomDocumentID() {
    final String characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    final String id = String.fromCharCodes(
      Iterable.generate(20, (_) => characters.codeUnitAt(random.nextInt(characters.length))),
    );
    return id;
  }

  Future<bool> isDocumentIDUnique(String id) async {
    final DocumentSnapshot document = await studentCollection.doc(id).get();
    return !document.exists;
  }

  void createStudent() async {
    if (documentID.isEmpty) {
      documentID = generateRandomDocumentID();
    }

    final isUnique = await isDocumentIDUnique(documentID);
    if (!isUnique) {
      // Alert the user that the ID is not unique
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Duplicate Document ID'),
            content: Text('The Document ID already exists. Please choose a different one.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // The ID is unique, proceed with data creation
      await studentCollection.doc(documentID).set({
        'name': newName,
        'isDeleted': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        });
    }
  }

  void updateStudent() {
    studentCollection.doc(documentID).update({
      'name': newName,
      'isDeleted': false,
      'updated_at': FieldValue.serverTimestamp(),
      });
  }

  void deleteStudent() {
    studentCollection.doc(documentID).update({
      'isDeleted': true,
      'deleted_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore CRUD Operations'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  newName = value;
                });
              },
              decoration: InputDecoration(labelText: 'New Name'),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  documentID = value;
                });
              },
              decoration: InputDecoration(labelText: 'Document ID (Leave empty to generate)'),
            ),
            ElevatedButton(
              onPressed: () {
                createStudent();
              },
              child: Text('Create'),
            ),
            ElevatedButton(
              onPressed: () {
                updateStudent();
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteStudent();
              },
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewStudentsScreen()),
                );
              },
              child: Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}