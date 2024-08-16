import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/resources/app_colors.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final String subjectName;

  const QuizPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.subjectName,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? quizStream;
  int currentQuestionIndex = 0;
  List<String?> selectedAnswers = [];
  bool hasTakenQuiz = false;

  @override
  void initState() {
    super.initState();
    _checkIfQuizTaken();
    String path = 'subjects/${widget.subjectName}/quizzes/${widget.quizId}';
    quizStream = FirebaseFirestore.instance.doc(path).snapshots();
  }

  Future<void> _checkIfQuizTaken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = await FirebaseFirestore.instance
          .collection('results')
          .where('quizId', isEqualTo: widget.quizId)
          .where('studentId', isEqualTo: user.uid)
          .get();

      if (result.docs.isNotEmpty) {
        setState(() {
          hasTakenQuiz = true;
        });
      }
    }
  }

  int calculateScore(List<dynamic> questions, List<String?> selectedAnswers) {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswer']) {
        score++;
      }
    }
    return score;
  }

  void saveQuizResult(int score, int totalQuestions) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      if (studentSnapshot.exists) {
        final studentData = studentSnapshot.data();

        await FirebaseFirestore.instance.collection('results').add({
          'quizId': widget.quizId,
          'quizTitle': widget.quizTitle,
          'subjectName': widget.subjectName,
          'score': score,
          'totalQuestions': totalQuestions,
          'studentId': user.uid,
          'name': studentData?['name'],
          'email': studentData?['email'],
          'gradeLevel': studentData?['gradeLevel'],
          'timestamp': Timestamp.now(),
        });
      }
    }
  }

  void showScoreDialog(BuildContext context, int score, int totalQuestions) {
    saveQuizResult(score, totalQuestions);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Finished'),
          content: Text('Your score is $score out of $totalQuestions.'),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.primaryColorLight),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasTakenQuiz) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quizTitle),
        ),
        body: const Center(
          child: Text("You have already taken this quiz."),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: quizStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text("No data available"),
            ),
          );
        }

        var quizData = snapshot.data!.data();

        if (quizData == null) {
          return const Scaffold(
            body: Center(
              child: Text("Quiz data is null"),
            ),
          );
        }

        if (!quizData.containsKey('questions') ||
            quizData['questions'] == null ||
            (quizData['questions'] as List).isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text("No questions available"),
            ),
          );
        }

        var questions = quizData['questions'] as List<dynamic>;

        if (selectedAnswers.length != questions.length) {
          selectedAnswers = List<String?>.filled(questions.length, null);
        }

        var currentQuestion = questions[currentQuestionIndex];

        return Scaffold(
          backgroundColor: Theme.of(context).canvasColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            title: Text(
              widget.quizTitle,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  currentQuestion["question"] ?? "No question text available",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .04,
                ),
                ...currentQuestion["options"]
                    .map<Widget>((option) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedAnswers[currentQuestionIndex] ==
                                      option
                                  ? AppColors.primaryColorLight
                                  : Colors.grey.shade300,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: RadioListTile(
                            selected: selectedAnswers[currentQuestionIndex] ==
                                option,
                            activeColor: AppColors.primaryColorLight,
                            title: Text(
                              option,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                            value: option,
                            groupValue: selectedAnswers[currentQuestionIndex],
                            onChanged: (value) {
                              setState(() {
                                selectedAnswers[currentQuestionIndex] = value;
                              });
                            },
                          ),
                        ))
                    .toList(),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentQuestionIndex > 0
                          ? () {
                              setState(() {
                                currentQuestionIndex--;
                              });
                            }
                          : null,
                      child: Text("Previous",
                          style: currentQuestionIndex > 0
                              ? const TextStyle(color: AppColors.primaryColorLight)
                              : null),
                    ),
                    Text("${currentQuestionIndex + 1} of ${questions.length} "),
                    currentQuestionIndex < questions.length - 1
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            },
                            child: const Text("Next",
                                style: TextStyle(
                                    color: AppColors.primaryColorLight)),
                          )
                        : ElevatedButton(
                            onPressed: selectedAnswers.any((answer) => answer != null)
                                ? () {
                                    int score = calculateScore(
                                        questions, selectedAnswers);
                                    showScoreDialog(
                                        context, score, questions.length);
                                  }
                                : null,
                            child: const Text("Finish",
                                style: TextStyle(
                                    color: AppColors.primaryColorLight)),
                          ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
