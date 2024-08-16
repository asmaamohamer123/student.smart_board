import 'package:flutter/material.dart';
import 'package:smartboard/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartboard/screens/home/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIDController = TextEditingController();
  final TextEditingController studentGradeLevelController =
      TextEditingController();
  final TextEditingController studentPhoneNumberController =
      TextEditingController();

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('...جاري انشاء حسابك'),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  void _showSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم';
    }
    return null;
  }

  String? _validateStudentID(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الرقم القومي';
    }
    if (value.length < 14) {
      return 'يرجى ادخال الرقم صحيح';
    }
    return null;
  }

  String? _validateStudentGradeLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال المستوي';
    }
    return null;
  }

  String? _validateStudentPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم التليفون';
    }
    if (value.length < 11) {
      return 'يرجى ادخال الرقم صحيح';
    }
    return null;
  }

  final GlobalKey<FormState> formKey = GlobalKey();
  bool showPassword = true;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 250,
                          width: 250,
                          child: Image.asset('assets/images/splash.jpeg'),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        controller: nameController,
                        labelText: 'اسم الطالب',
                        prefixIcon: Icons.person,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 15.0),
                      CustomTextField(
                        controller: emailController,
                        labelText: 'عنوان البريد الالكترونى',
                        prefixIcon: Icons.email,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15.0),
                      CustomTextField(
                        controller: passwordController,
                        labelText: 'كلمه المرور',
                        prefixIcon: Icons.lock,
                        obscureText: showPassword,
                        validator: _validatePassword,
                        suffixIcon: IconButton(
                          icon: showPassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      CustomTextField(
                        controller: studentIDController,
                        labelText: 'الرقم القومي',
                        prefixIcon: Icons.badge,
                        validator: _validateStudentID,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15.0),
                      CustomTextField(
                        controller: studentGradeLevelController,
                        labelText: 'المستوي',
                        prefixIcon: Icons.numbers,
                        validator: _validateStudentGradeLevel,
                      ),
                      const SizedBox(height: 15.0),
                      CustomTextField(
                        controller: studentPhoneNumberController,
                        labelText: 'رقم التليفون',
                        prefixIcon: Icons.phone_android,
                        validator: _validateStudentPhoneNumber,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30.0),
                      Center(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xff2e386b),
                          ),
                          child: MaterialButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                _showLoadingDialog();

                                try {
                                  final newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('students')
                                      .doc(newUser.user!.uid)
                                      .set({
                                    'userId': newUser.user!.uid,
                                    'name': nameController.text,
                                    'email': emailController.text,
                                    'studentID': studentIDController.text,
                                    'gradeLevel':
                                        studentGradeLevelController.text,
                                    'phoneNumber':
                                        studentPhoneNumberController.text,
                                  });

                                  _hideLoadingDialog();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          HomeScreens(),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  _hideLoadingDialog();
                                  if (e.code == 'email-already-in-use') {
                                 _showSnackbar(context, 'البريد الإلكتروني مستخدم بالفعل.');

                                  } else {
                                    _showSnackbar(context,'حدث خطأ: ${e.message}');
                                  }
                                } catch (e) {
                                  _hideLoadingDialog();
_showSnackbar(context, 'حدث خطأ غير متوقع.');
                                }
                              }
                            },
                            child: const Text(
                              'انشاء حساب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
