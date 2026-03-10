
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ButtonSaveAction extends StatelessWidget {
  const ButtonSaveAction({
    super.key,
    required LatLng? selectedDestination,
    required double alarmRadius,
  }) : _selectedDestination = selectedDestination, _alarmRadius = alarmRadius;

  final LatLng? _selectedDestination;
  final double _alarmRadius;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pop(context, {
            'latitude': _selectedDestination!.latitude,
            'longitude': _selectedDestination!.longitude,
            'radius': _alarmRadius,
            'title': 'المنبه الجغرافي', // يمكن تطويره لاحقاً لاختيار اسم
            'ringtone': 'assets/audio/alarm.mp3', // نغمة افتراضية
          });
        },
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'حفظ المنبه هنا',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
  }
}