import 'package:flutter/material.dart';
import 'trip_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String email;
  const HomeScreen({required this.name, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TripListScreen(
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("여행 기록 앱")),
      body: Center(
        child: Text(
          "${widget.name}님, 환영합니다!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
