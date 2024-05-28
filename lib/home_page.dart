import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "Stop service";
  int okCount = 9;
  int notOkCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  _loadCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      okCount = (prefs.getInt('okCount') ?? 0);
      notOkCount = (prefs.getInt('notOkCount') ?? 0);
      print("okCount : ${okCount} , ontOkCount : ${notOkCount}");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke('setAsForeground');
            }, child: Text("Successful request : ${okCount}")),
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke('setAsBackground');
            }, child: Text("Unsuccessful request : ${notOkCount}")),
            ElevatedButton(onPressed: () async{
              final service = FlutterBackgroundService();
              bool isRunning = await service.isRunning();
              if(isRunning) {
                service.invoke("stopService");

              }else {
                service.startService();
              }

              if(!isRunning) {
                text = "Stop Service";
              }else {
                text = "Start Service";
              }
              setState(() {

              });
            }, child: Text("${text}")),
          ],
        ),
      ),
    );
  }
}
