import 'dart:async';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializedService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
        onStart: onStart, isForegroundMode: true, autoStart: true),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

void onStart(ServiceInstance service) async{
  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if(service is AndroidServiceInstance) {
      if(await service.isForegroundService()) {
        service.setForegroundNotificationInfo(title: "Script Academy", content: "Subscribe my channel");
      }
    }
    try {
      final response = await http.get(Uri.parse('https://api.first.org/data/v1/countries'));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int okCount = prefs.getInt('okCount') ?? 0;
      int notOkCount = prefs.getInt('notOkCount') ?? 0;

      print("ok notok count : ${okCount} , ${notOkCount}");

      if(response.statusCode == 200){
        print("status : 200");
        print("${response.body}");
        okCount++;
        await prefs.setInt('okCount', okCount);
      }else {
        print("status : 500");
        notOkCount++;
        await prefs.setInt('notOkCount', notOkCount);
      }
    }
    on Exception catch (_, ex) {
      print(ex);
    }

    print("background service running");
    service.invoke('update');
  });
}
