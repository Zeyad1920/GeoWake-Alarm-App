import 'package:flutter/material.dart';

class AlarmCardWidget extends StatelessWidget {
  final String title;
  final String time;  
  final String amPm; // سيكون فارغاً في حالة الموقع
  final String days;
  final bool isActive;
  final bool isLocation; 
  final ValueChanged<bool> onToggle;

  const AlarmCardWidget({
    Key? key,
    required this.title,
    required this.time,
    required this.amPm,
    required this.days,
    required this.isActive,
    required this.onToggle,
    this.isLocation = false, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (isLocation) 
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                  if (isLocation) 
                    const SizedBox(width: 4),

                  Text(
                    time, 
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontSize: isLocation ? 28 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  
                  if (!isLocation) 
                    Text(
                      amPm,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey, 
                        fontSize: 16, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                days, 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
            ],
          ),
          Switch(
            value: isActive,
            activeColor: Colors.blue,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}