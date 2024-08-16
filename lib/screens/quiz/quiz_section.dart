import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartboard/screens/quiz/quiz_screen.dart';

class QuizzesSection extends StatelessWidget {
  final String subjectName;
  const QuizzesSection({super.key, required this.subjectName});

  Stream<Map<String, int?>> _getStudentScoreAndTotalQuestions(
      String quizId) async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) yield {'score': null, 'totalQuestions': null};

    await for (var snapshot in FirebaseFirestore.instance
        .collection('results')
        .where('quizId', isEqualTo: quizId)
        .where('studentId', isEqualTo: user!.uid)
        .snapshots()) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        yield {
          'score': data['score'],
          'totalQuestions': data['totalQuestions']
        };
      } else {
        yield {'score': null, 'totalQuestions': null};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectName)
          .collection('quizzes')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var quizzes = snapshot.data!.docs;

        if (quizzes.isEmpty) {
          return const Center(child: Text('No quizzes found.'));
        }

        return ListView.builder(
          itemCount: quizzes.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            var quiz = quizzes[index];
            return StreamBuilder<Map<String, int?>>(
              stream: _getStudentScoreAndTotalQuestions(quiz.id),
              builder: (context, scoreSnapshot) {
                if (!scoreSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool hasTakenQuiz = scoreSnapshot.data != null &&
                    scoreSnapshot.data!['score'] != null;
                int? score = scoreSnapshot.data?['score'];
                int? totalQuestions = scoreSnapshot.data?['totalQuestions'];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      quiz['quizTitle'] ?? 'Quiz',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: hasTakenQuiz ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle:
                        hasTakenQuiz && score != null && totalQuestions != null
                            ? Text(
                                'Your Score: $score/$totalQuestions',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                    trailing: hasTakenQuiz
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.arrow_forward_ios),
                    onTap: hasTakenQuiz
                        ? null // Disable tap if the quiz is already taken
                        : () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return QuizPage(
                                subjectName: subjectName,
                                quizId: quiz.id,
                                quizTitle: quiz['quizTitle'],
                              );
                            }));
                          },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
