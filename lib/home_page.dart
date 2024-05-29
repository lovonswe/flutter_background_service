import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "Stop service";
  int okCount = StateManager().okCount;
  int notOkCount = StateManager().notOkCount;

  @override
  void initState() {
    super.initState();
    _loadCounts();
    StateManager().addListener(_updateCounts);
  }

  @override
  void dispose() {
    StateManager().removeListener(_updateCounts);
    super.dispose();
  }

  _loadCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      StateManager().updateCounts(
        prefs.getInt('okCount') ?? 0,
        prefs.getInt('notOkCount') ?? 0,
      );
    });
  }

  void _updateCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      okCount = prefs.getInt('okCount') ?? okCount;
      notOkCount = prefs.getInt('notOkCount') ?? notOkCount;
      // Explicitly update the UI with the latest counts
    });
  }

  @override
  Widget build(BuildContext context) {
    // int okCount = StateManager().okCount;
    // int notOkCount = StateManager().notOkCount;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke('setAsForeground');
            }, child: Text("Successful request : $okCount")),
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke('setAsBackground');
            }, child: Text("Unsuccessful request : $notOkCount")),
            ElevatedButton(onPressed: () async {
              final service = FlutterBackgroundService();
              bool isRunning = await service.isRunning();
              if (isRunning) {
                service.invoke("stopService");
              } else {
                service.startService();
              }

              setState(() {
                text = isRunning ? "Start Service" : "Stop Service";
              });
            }, child: Text("$text")),
          ],
        ),
      ),
    );
  }
}
