import 'package:flutter/material.dart';

class BuildRadiusSlider  extends StatelessWidget {
  final double alarmRadius; // 
  final ValueChanged<double> onChanged; 

  const BuildRadiusSlider({
    Key? key,
    required this.alarmRadius,
    required this.onChanged,
  }) : super(key: key);
  @override
  
  Widget build(BuildContext context) {
     
   
    return Positioned(
      bottom: 80, left: 20, right: 20,
      child: Card(
        color: const Color(0xFF1E2228).withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("قطر التنبيه: ${alarmRadius.toInt()} متر", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Slider(
                value: alarmRadius, min: 100, max: 5000, divisions: 49,
                activeColor: Colors.blue, inactiveColor: Colors.grey,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  
