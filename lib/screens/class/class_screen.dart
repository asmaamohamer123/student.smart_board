import 'package:flutter/material.dart';
import 'package:smartboard/screens/assigments/assigment.dart';
import 'package:smartboard/screens/quiz/quiz_section.dart';
import '../../core/resources/app_colors.dart';
import '../lectures/content.dart';


class ClassPage extends StatefulWidget {
  const ClassPage({
    super.key,
    required this.className,
  });
  final String className;

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: AppBar(
          title: Text(
            widget.className,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          bottom: TabBar(
            labelStyle: const TextStyle(fontSize: 16),
            dividerColor: Colors.grey.shade400,
            labelColor: AppColors.primaryColorLight,
            indicatorColor: AppColors.primaryColorLight,
            tabs: const [
              Tab(text: 'Content'),
              Tab(text: 'Quizzes'),
              Tab(text: 'Assignments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ContentSection(subjectName: widget.className),
            QuizzesSection(subjectName: widget.className),
            AssignmentsSection(subjectName: widget.className),
          ],
        ),
      ),
    );
  }
}



