import 'package:adzan_application/widgets/prayerTimesWidget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
          backgroundColor: const Color(0xFF0B6623),
          centerTitle: true
        ),
        body: PrayerTimesWidget(),
      ),
    );
  }
}
