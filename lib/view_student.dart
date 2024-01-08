import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStudentsScreen extends StatefulWidget {
  const ViewStudentsScreen({Key? key}) : super(key: key);

  @override
  _ViewStudentsScreenState createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('student');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Students'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: studentCollection.where('isDeleted', isEqualTo: false).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final students = snapshot.data!.docs;
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final data = student.data() as Map<String, dynamic>;
                final name = data['name'] as String;
                final documentID = student.id;
                return ListTile(
                  title: Text('Name: $name'),
                  subtitle: Text('Document ID: $documentID'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
