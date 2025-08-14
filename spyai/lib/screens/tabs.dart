import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spyai/screens/chat.dart';
import 'package:spyai/screens/recording.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  final pages = [RecordingScreen(), ChatScreen()];
  int index = 0;

  void _selectPage(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Spy AI",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 28, 48),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 3, 28, 48),
        selectedItemColor: const Color.fromARGB(255, 1, 129, 241),
        unselectedItemColor: Colors.white,
        onTap: _selectPage,
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.userSecret),
            label: 'Spy',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
      body: SafeArea(child: pages[index]),
    );
  }
}
