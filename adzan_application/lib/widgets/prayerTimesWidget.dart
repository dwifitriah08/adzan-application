import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'prayerTimesTileWidget.dart';
import '../utils/notificationHelper.dart';
import '../models/idLocale.dart';
import '../utils/locationHelper.dart';
import '../utils/prayerTimesHelper.dart';
import '../utils/alarmHelper.dart';

class PrayerTimesWidget extends StatefulWidget {
  @override
  _PrayerTimesWidgetState createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  Timer? _timer;
  PrayerTimes? _prayerTimes;
  Coordinates? _myCoordinates;
  List<bool> alarmFlag = Prayer.values.map((v) {
    return false;
  }).toList();

  Future<void> _initStateAsync() async {
    final params = await getPrayerParams();
    _myCoordinates ??= await getSavedCoordinates();
    _prayerTimes ??= PrayerTimes.today(_myCoordinates, params);

    Prayer.values.forEach((p) async {
      alarmFlag[p.index] = await getAlarmFlag(p.index);
      setAlarmNotification(_prayerTimes!, p.index, alarmFlag[p.index]);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      final _params = await getPrayerParams();
      final coords = await getSavedCoordinates();
      setState(() {
        _prayerTimes = PrayerTimes.today(coords, _params);
      });
    });
  }

  @override
  void initState() {
    _refreshFunc();
    _initStateAsync().then((_) => setState((){}));
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
                  onRefresh: () async {
                    _refreshFunc();
                  },
      child: FutureBuilder(
          future: _genListViewItems(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return snapshot.data![index];
                  });
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<List<Widget>> _genListViewItems() async {
    List<Widget> listViewItems = [];
    listViewItems.add(ListTile(
      title: Text(
        _getHijriFullDate(),
      ),
    ));
    listViewItems.add(ListTile(
      leading: IconButton(
        icon: const Icon(Icons.refresh_outlined),
        onPressed: () => _refreshFunc(),
      ),
      title: const Text('Lokasi'),
      subtitle: _myCoordinates != null
          ? Text(
              _myCoordinates!.latitude.toStringAsFixed(5) +
                  ', ' +
                  _myCoordinates!.longitude.toStringAsFixed(5)
            )
          : const Text(''),
          trailing: IconButton(
            icon: const Icon(Icons.info), 
            onPressed: () { 
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                    title: Text('Turn on your location'),
                    content: Text('Aktifkan GPS dan refresh lokasi saat pertama kali akses aplikasi untuk menentukan waktu sholat sesuai lokasimu!'),
                )
            );
             },
          ),
    ));
    Prayer.values.forEach((p) {
      if (p != Prayer.none)
        listViewItems.add(
          PrayerTimesTileWidget(
            prayerTimes: _prayerTimes,
            prayer: p,
            prayerName: prayerNames[p.index],
            prayerTime: DateFormat.jm('in_ID').format(_prayerTimes!.timeForPrayer(p)),
            disableFlag: p == Prayer.sunrise ? true : false,
            timeDuration: getTimeDiff(_prayerTimes!.timeForPrayer(p)),
            onFlag: alarmFlag[p.index],
            onAlarmPressed: () =>
                _onAlarmPressed(p.index, _prayerTimes!.timeForPrayer(p)),
          ),
        );
    });

    return listViewItems;
  }

  String _getHijriFullDate() {
    var hijri = HijriCalendar.now();
    return hariNames[hijri.wkDay]! +
        ", " +
        hijri.hDay.toString() +
        " " +
        bulanNames[hijri.hMonth]! +
        " " +
        hijri.hYear.toString();
  }

  _onAlarmPressed(int index, DateTime prayerTime) {
    bool flag = !alarmFlag[index];
    setAlarmNotification(_prayerTimes!, index, flag);
    saveAlarmFlag(index, flag);
    setState(() {
      alarmFlag[index] = flag;
    });
  }

  _refreshFunc() {
    getCoordinates().then((coordinates) {
      if (coordinates == null) return;
      if (_myCoordinates != null) {
        if (_myCoordinates!.latitude.toStringAsFixed(4) ==
                coordinates.latitude.toStringAsFixed(4) &&
            _myCoordinates!.longitude.toStringAsFixed(4) ==
                coordinates.longitude.toStringAsFixed(4)) return;
      }
      _setNewCoordinates(coordinates);
    });
  }

  _setNewCoordinates(Coordinates coordinates) async {
    final params = await getPrayerParams();
    var prayerTimes = PrayerTimes.today(coordinates, params);
    Prayer.values.forEach((p) {
      turnOffNotificationById(FlutterLocalNotificationsPlugin(), p.index);
      setAlarmNotification(_prayerTimes!, p.index, alarmFlag[p.index]);
    });


    _prayerTimes = prayerTimes;

    saveCoordinates(coordinates);
    setState(() {
      _myCoordinates = coordinates;
    });
  }
}
