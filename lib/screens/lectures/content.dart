import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartboard/screens/class/show_file.dart';
import 'package:smartboard/screens/class/widgets/custom_listTile.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentSection extends StatelessWidget {
  final String subjectName;
  const ContentSection({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectName)
          .collection('lectures')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var lectures = snapshot.data!.docs;

        if (lectures.isEmpty) {
          return const Center(child: Text('No lectures found.'));
        }

        return ListView.builder(
          itemCount: lectures.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            var lecture = lectures[index];
            return customListTile(
              title: lecture['file_name'] ?? 'Lecture',
              downloadButton: () {
                _launchURL(lecture['file_url']);
              },
              viewButton: () {
                openFile(context, lecture['file_url']);
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
