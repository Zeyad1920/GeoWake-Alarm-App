import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:clock_app/core/datebase/db_sql_lite.dart'; 

class AlarmRingingDialog extends StatelessWidget {
  final int alarmId;
  final VoidCallback onAlarmStopped; 

  const AlarmRingingDialog({
    Key? key,
    required this.alarmId,
    required this.onAlarmStopped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2228),
      title: const Text("⏰ Wake Up!", style: TextStyle(color: Colors.white)),
      content: const Text("Your alarm is ringing right now.", style: TextStyle(color: Colors.white70)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            try {
              // إيقاف المنبه
              await Alarm.stop(alarmId);
              await Alarm.stopAll(); 
            } finally {
              // إغلاق النافذة
              if (context.mounted) Navigator.pop(context);
              
              // تحديث قاعدة البيانات
              await DatabaseHelper.instance.updateAlarmStatus(alarmId, 0);
              
              onAlarmStopped(); 
            }
          },
          child: const Text("STOP ALARM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}