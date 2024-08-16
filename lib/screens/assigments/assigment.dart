import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartboard/screens/class/show_file.dart';
import 'package:smartboard/screens/class/widgets/custom_listTile.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentsSection extends StatelessWidget {
  final String subjectName;
  const AssignmentsSection({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectName)
          .collection('assignments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var assignments = snapshot.data!.docs;

        if (assignments.isEmpty) {
          return const Center(child: Text('No assignments found.'));
        }

        return ListView.builder(
          itemCount: assignments.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            var assignment = assignments[index];
            return customListTile(
              title: assignment['file_name'] ?? 'Assignment',
              downloadButton: () {
                _launchURL(assignment['file_url']);
              },
              viewButton: () {
                openFile(context, assignment['file_url']);
              },
            );
          },
        );
      },
    );
  }

  void openFile(BuildContext context, String fileUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(fileUrl),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
