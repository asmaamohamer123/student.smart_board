import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartboard/core/resources/app_colors.dart';
import 'package:smartboard/screens/class/class_screen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smartboard/screens/home/widgets/custom_card_news.dart';
import 'package:smartboard/screens/home/widgets/custom_class_item.dart';
import 'package:smartboard/screens/login/new_login.dart';

class HomeScreens extends StatefulWidget {
  HomeScreens({super.key});

  final _auth = FirebaseAuth.instance;
  late User signedinuser;

  @override
  void initState() {
    getcurrentuser();
  }

  void getcurrentuser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedinuser = user;
        print(signedinuser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? newsCollection;
  Stream<QuerySnapshot<Map<String, dynamic>>>? subjectsCollection;
  Stream<QuerySnapshot<Map<String, dynamic>>>? scheduleCollection;

  @override
  void initState() {
    super.initState();
    newsCollection = FirebaseFirestore.instance.collection('news').snapshots();
    subjectsCollection =
        FirebaseFirestore.instance.collection('subjects').snapshots();
    scheduleCollection =
        FirebaseFirestore.instance.collection('materials').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "FCI",
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showLogoutDialog(context);
            },
          ),
        ],
        backgroundColor: AppColors.backGroundColorLightMode,
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
              stream: newsCollection,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List news = snapshot.data!.docs;
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .25,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: news.length,
                            itemBuilder: (context, index) {
                              return CustomCardNews(
                                path: news[index]['pathImage'],
                                text: news[index]['description'],
                              );
                            }),
                      ),
                    ),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .25,
                        child: Text(
                          "No Data",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: AppColors.colorGray),
                        ),
                      ),
                    ),
                  );
                }
              }),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Materials",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
                stream: subjectsCollection,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> subjects = snapshot.data!.docs;

                    // Print subjects for debugging
                    print("Retrieved Subjects:");
                    for (var subject in subjects) {
                      print("Subject ID: ${subject.id}, Data: ${subject.data()}");
                    }

                    return AnimationLimiter(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: subjects.length,
                        itemBuilder: (BuildContext context, int index) {
                          String subjectName = subjects[index].id;
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 800),
                            child: CustomClassItem(
                              className: subjectName,
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ClassPage(
                                    className: subjectName,
                                  );
                                }));
                              }, subtitle: '',
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Center(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .5,
                        child: Text(
                          "No Data",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: AppColors.colorGray),
                        ),
                      ),
                    );
                  }
                }),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
                stream: scheduleCollection,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> materials = snapshot.data!.docs;
                    String scheduleImage = materials.first.get("scheduleImage");

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Schedule",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return Container(
                                    height:
                                        MediaQuery.of(context).size.height * .9,
                                    color: AppColors.backGroundColorLightMode,
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back,
                                              color:
                                                  AppColors.primaryColorLight,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: PhotoView(
                                            backgroundDecoration:
                                                const BoxDecoration(
                                              color: AppColors
                                                  .backGroundColorLightMode,
                                            ),
                                            imageProvider:
                                                NetworkImage(scheduleImage),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image(
                              width: MediaQuery.of(context).size.width * 0.9,
                              image: NetworkImage(scheduleImage),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .5,
                        child: Text(
                          "No Data",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: AppColors.colorGray),
                        ),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('تسجيل خروج'),
      content: const Text(' هل أنت متأكد أنك تريد تسجيل الخروج؟'),
      actions: [
        TextButton(
          child: const Text('الغاء'),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
        TextButton(
          child: const Text('تسجيل خروج'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
