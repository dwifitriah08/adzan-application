import 'package:adzan_application/models/idLocale.dart';
import 'package:adzan_application/utils/notificationHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

void _enableAlarmNotification(PrayerTimes prayerTimes, int prayerIndex) {
  Prayer prayer = Prayer.values[prayerIndex];
  DateTime prayerTime = prayerTimes.timeForPrayer(prayer);

  scheduleNotification(
      FlutterLocalNotificationsPlugin(),
      prayerIndex,
      prayer.toString(),
      'Pengingat Sholat',
      'Saatnya Sholat: ' +
          prayerNames[prayerIndex] +
          ', Pukul ' +
          prayerTime.hour.toString() +
          ':' +
          prayerTime.minute.toString(),
      prayerTime);
}

void setAlarmNotification(
    PrayerTimes prayerTimes, int prayerIndex, bool enableFlag) {
  turnOffNotificationById(FlutterLocalNotificationsPlugin(), prayerIndex);
  if (enableFlag) {
    _enableAlarmNotification(prayerTimes, prayerIndex);
  }
}

Future<void> saveAlarmFlag(int index, bool flag) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('alarm$index', flag);
}

Future<bool> getAlarmFlag(int index) async {
  bool flag = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('alarm$index')) {
    flag = prefs.getBool('alarm$index')!;
  }
  return flag;
}
