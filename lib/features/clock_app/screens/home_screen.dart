import 'package:flutter/material.dart';
import 'package:clock_app/core/datebase/db_sql_lite.dart';
import 'package:clock_app/features/clock_app/screens/add_alarm_screen.dart';
import 'package:clock_app/features/clock_app/widgets/alarm_card_widget.dart';
import 'package:alarm/alarm.dart';
import 'dart:async';
import 'package:clock_app/features/clock_app/widgets/alarm_ringing_dialog.dart'; 
import 'package:clock_app/core/utils/alarm_helper.dart'; 
import 'package:geolocator/geolocator.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allAlarms = [];
  bool _isLoading = true;
  
  StreamSubscription<AlarmSettings>? _ringSubscription;
  StreamSubscription<Position>? _locationSubscription; 

  @override
  void initState() {
    super.initState();
    _loadAllAlarms();
    
    _ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      _showRingingDialog(alarmSettings.id);
    });

    _startLocationRadar(); 
  }

  @override
  void dispose() {
    _ringSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  // =====================================
  // 📍 عقل رادار الموقع (الذي يراقب حركتك)
  // =====================================
  void _startLocationRadar() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) async {
      _checkAlarmsAgainstPosition(position);
    });
  }

  Future<void> _checkLocationAlarmsNow() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    // التقاط الموقع الحالي فوراً لمرة واحدة
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _checkAlarmsAgainstPosition(position);
  }

  // دالة مشتركة لفحص المسافات
  Future<void> _checkAlarmsAgainstPosition(Position position) async {
    final db = await DatabaseHelper.instance.database;
    final activeLocationAlarms = await db.query(
      'alarms', 
      where: 'isLocation = ? AND isActive = ?', 
      whereArgs: [1, 1], 
    );

    for (var alarm in activeLocationAlarms) {
      double lat = alarm['latitude'] as double;
      double lng = alarm['longitude'] as double;
      double radius = alarm['radius'] as double;
      int id = alarm['id'] as int;

      double distance = Geolocator.distanceBetween(position.latitude, position.longitude, lat, lng);

      if (distance <= radius) {
        _triggerLocationAlarm(id, alarm['ringtone'] as String, alarm['title'] as String);
      }
    }
  }

  Future<void> _triggerLocationAlarm(int alarmId, String ringtone, String title) async {
    await DatabaseHelper.instance.updateAlarmStatus(alarmId, 0);
    _loadAllAlarms(); 

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: DateTime.now().add(const Duration(seconds: 1)),
      assetAudioPath: ringtone,
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(volume: 1.0),
      notificationSettings: NotificationSettings(
        title: '📍 لقد وصلت للهدف!',
        body: title.isEmpty ? 'أنت الآن داخل نطاق المنبه' : title,
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  void _showRingingDialog(int id) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlarmRingingDialog(
        alarmId: id,
        onAlarmStopped: () {
          _loadAllAlarms(); 
        },
      ),
    );
  }

  Future<void> _loadAllAlarms() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('alarms', orderBy: 'id DESC'); 
    
    setState(() {
      _allAlarms = data.map((map) => Map<String, dynamic>.from(map)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Alarms', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _allAlarms.isEmpty
              ? const Center(child: Text("No alarms yet. Add one!", style: TextStyle(color: Colors.grey, fontSize: 18)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _allAlarms.length,
                  itemBuilder: (context, index) {
                    final alarm = _allAlarms[index];
                    int alarmId = alarm['id'];
                    bool isLocation = alarm['isLocation'] == 1;

                    return Dismissible(
                      key: Key(alarmId.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(15)),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),
                      onDismissed: (_) async {
                        setState(() => _allAlarms.removeAt(index));
                        await DatabaseHelper.instance.deleteAlarm(alarmId);
                        if (!isLocation) await Alarm.stop(alarmId); 
                      },
                      child: AlarmCardWidget(
                        title: alarm['title'],
                        time: isLocation ? "${alarm['radius'].toInt()} متر" : alarm['time'],
                        amPm: isLocation ? "" : alarm['amPm'],
                        days: alarm['days'],
                        isActive: alarm['isActive'] == 1,
                        isLocation: isLocation,
                        
                        onToggle: (val) async {
                          if (isLocation) {
                            await DatabaseHelper.instance.updateAlarmStatus(alarmId, val ? 1 : 0);
                            if (val) _checkLocationAlarmsNow(); 
                          } else {
                            await AlarmHelper.toggleAlarmData(alarmId, val, alarm);
                          }
                          _loadAllAlarms();
                        },
                      ),
                    );
                  },
                ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
          );
          if (result == true) { 
            _loadAllAlarms();
            _checkLocationAlarmsNow();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}