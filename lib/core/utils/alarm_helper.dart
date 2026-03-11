import 'package:alarm/alarm.dart';
import 'package:clock_app/core/constants/assets.dart';
import 'package:clock_app/core/datebase/db_sql_lite.dart';
import 'package:clock_app/features/clock_app/models/ring_tones.dart';
import 'package:flutter/material.dart';

class AlarmHelper {
  
  static Future<List<Map<String, dynamic>>> getAlarms() async {
    final data = await DatabaseHelper.instance.getTimeAlarms();
    return data.map((map) => Map<String, dynamic>.from(map)).toList();
  }

  static Future<void> scheduleTimeAlarm(int alarmId, String timeStr, String amPm, String ringtone, String title) async {
    List<String> parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (amPm == 'PM' && hour != 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    final now = DateTime.now();
    
    DateTime nowWithoutSeconds = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    
    DateTime newAlarmTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (newAlarmTime.isBefore(nowWithoutSeconds)) {
      newAlarmTime = newAlarmTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: newAlarmTime,
      assetAudioPath: ringtone,
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(volume: 0.5),
      notificationSettings: NotificationSettings(
        title: '⏰ Wake Up!',
        body: title.isEmpty ? 'Your alarm is ringing' : title,
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  // 3. حفظ منبه (وقت) جديد
  static Future<void> saveTimeAlarm(Map<String, dynamic> data) async {
    TimeOfDay selectedTime = data['time'];
    List<bool> selectedDays = data['days'];
    String title = data['title'] ?? 'Alarm';
    String ringtonePath = data['ringtone'] ?? ringtones[0]['path']!;

    String hour = selectedTime.hourOfPeriod.toString().padLeft(2, '0');
    if (selectedTime.hourOfPeriod == 0) hour = '12';
    String minute = selectedTime.minute.toString().padLeft(2, '0');
    String amPm = selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    String timeString = "$hour:$minute";

    List<String> activeDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        .asMap().entries.where((e) => selectedDays[e.key]).map((e) => e.value).toList();
    
    String daysString = activeDays.isEmpty ? "No Repeat" : activeDays.join(', ');

    int alarmId = await DatabaseHelper.instance.insertAlarm({
      'title': title,
      'time': timeString,
      'amPm': amPm,
      'days': daysString,
      'isActive': 1,
      'ringtone': ringtonePath,
      'isLocation': 0, 
    });

    await scheduleTimeAlarm(alarmId, timeString, amPm, ringtonePath, title);
  }

  // 4. حذف منبه نهائياً من النظام والداتا بيز
  static Future<void> deleteAlarmData(int alarmId) async {
    await Alarm.stop(alarmId);
    await DatabaseHelper.instance.deleteAlarm(alarmId);
  }

  // 5. تشغيل/إيقاف المنبه
  static Future<void> toggleAlarmData(int alarmId, bool isEnabled, Map<String, dynamic> alarm) async {
    await DatabaseHelper.instance.updateAlarmStatus(alarmId, isEnabled ? 1 : 0);

    if (!isEnabled) {
      await Alarm.stop(alarmId);
    } else {
      await scheduleTimeAlarm(
        alarmId,
        alarm['time'],
        alarm['amPm'],
        alarm['ringtone'] ?? Assets.assetsAudioAlarm,
        alarm['title'] ?? 'Alarm',
      );
    }
  }
}