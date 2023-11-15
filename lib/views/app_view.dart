import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/record_audio.dart';
import 'package:flutter_application_1/views/video_view.dart';

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
  final widgets = [const VideoView(), const RecorderView()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.school),
            icon: Icon(Icons.school_outlined),
            label: 'School',
          ),
        ],
      ),
      body: widgets[currentPageIndex],
    );
  }
}
