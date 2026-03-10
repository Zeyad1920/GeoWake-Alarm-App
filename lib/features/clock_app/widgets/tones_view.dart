import 'package:clock_app/features/clock_app/models/ring_tones.dart';
import 'package:flutter/material.dart';

class TonesView extends StatefulWidget {
  final String selectedRingtonePath;
  final ValueChanged<String> onChanged; 

  const TonesView({
    Key? key, 
    required this.selectedRingtonePath,
    required this.onChanged, 
  }) : super(key: key);

  @override
  State<TonesView> createState() => _TonesViewState();
}

class _TonesViewState extends State<TonesView> {
  late String selectedRingtonePath;

  @override
  void initState() {
    super.initState();
    selectedRingtonePath = widget.selectedRingtonePath;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRingtonePath,
          dropdownColor: const Color(0xFF1E2228),
          isExpanded: true,
          icon: const Icon(Icons.music_note, color: Colors.blue),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: ringtones.map((ringtone) {
            return DropdownMenuItem<String>(
              value: ringtone['path'],
              child: Text(ringtone['name']!),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedRingtonePath = newValue;
              });
              
              //  2. هنا السحر! نخبر الشاشة الأب بالمسار الجديد
              widget.onChanged(newValue); 
            }
          },
        ),
      ),
    );
  }
}