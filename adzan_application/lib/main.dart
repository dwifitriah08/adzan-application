import 'package:adzan_application/pages/homepage.dart';
import 'package:adzan_application/utils/locationHelper.dart';
import 'package:adzan_application/utils/notificationHelper.dart';
import 'package:adzan_application/utils/workerManagerHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails? notificationAppLaunchDetails;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);
  requestIOSPermissions(flutterLocalNotificationsPlugin);
  await requestLocationPermision();
  await initWorkerManager();
  await enablePeriodicTask(updatePrayerTimeTaskID, updatePrayerTimeTaskName,
          const Duration(hours: 12), {'date': DateTime.now().toString()});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: "Jadwal Sholat"),
    );
  }
}
