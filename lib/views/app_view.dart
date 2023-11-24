import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/record_audio.dart';
// import 'package:flutter_application_1/views/survey_view.dart';
import 'package:flutter_application_1/views/video_view.dart';

import '../widgets/appbar.dart';
import 'survey_view.dart';

/// Flutter code sample for [NavigationBar].

// class AppView extends StatelessWidget {
//   const AppView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(home: NavigationExample());
//   }
// }

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppView();
}

class _AppView extends State<AppView> {
  int currentPageIndex = 0;
  final widgets = [const VideoView(), const RecordList(), const QuestionView()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber[800],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.video_camera_back_outlined),
            icon: Icon(Icons.video_camera_back),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: Icon(Icons.audiotrack_outlined),
            label: 'Audios',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: 'Survey',
          ),
        ],
      ),
      body: widgets[currentPageIndex],
    );
  }
}
