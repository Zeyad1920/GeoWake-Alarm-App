import 'package:clock_app/core/datebase/db_sql_lite.dart';
import 'package:clock_app/core/utils/alarm_helper.dart';
import 'package:clock_app/features/clock_app/models/ring_tones.dart';
import 'package:clock_app/features/clock_app/screens/add_location_alarm_screen.dart';
import 'package:clock_app/features/clock_app/widgets/tones_view.dart';
import 'package:flutter/material.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({Key? key}) : super(key: key);

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  bool _isLocationAlarm = false; 

  // متغيرات الوقت
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // متغيرات الموقع
  double? _selectedLatitude;
  double? _selectedLongitude;
  double _selectedRadius = 500.0;

  // المتغيرات المشتركة
  final TextEditingController _titleController = TextEditingController();
  final List<String> _dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  late String _selectedRingtonePath;

  @override
  void initState() {
    super.initState();
    _selectedRingtonePath = ringtones[0]['path']!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  // 🗺️ دالة فتح الخريطة لاختيار الموقع
  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLocationAlarmScreen()),
    );
    
    if (result != null) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedRadius = result['radius'];
      });
    }
  }

  //  دالة الحفظ الذكية (تميز بين الوقت والموقع وتحفظ أيام التكرار)
  Future<void> _saveSmartAlarm() async {
    String finalTitle = _titleController.text.trim().isEmpty ? (_isLocationAlarm ? 'Location Alarm' : 'Alarm') : _titleController.text.trim();

    //  حساب أيام التكرار المحددة (سواء كان المنبه وقت أو موقع)
    List<String> activeDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        .asMap().entries.where((e) => _selectedDays[e.key]).map((e) => e.value).toList();
    String daysString = activeDays.isEmpty ? "No Repeat" : activeDays.join(', ');

    if (!_isLocationAlarm) {
      // 1. حفظ منبه الوقت 
      await AlarmHelper.saveTimeAlarm({
        'time': _selectedTime,
        'days': _selectedDays, 
        'title': finalTitle,
        'ringtone': _selectedRingtonePath,
      });
    } else {
      // 2. حفظ منبه الموقع
      if (_selectedLatitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تحديد الموقع على الخريطة أولاً!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
        return;
      }
      
      await DatabaseHelper.instance.insertAlarm({
        'title': finalTitle,
        'time': '',
        'amPm': '',
        'days': daysString, 
        'isActive': 1,
        'ringtone': _selectedRingtonePath,
        'isLocation': 1,
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'radius': _selectedRadius,
      });
    }

    // إغلاق الشاشة وإرسال إشارة للـ HomeScreen لكي تتحدث
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text('Add Alarm', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- أزرار التبديل ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isLocationAlarm ? Colors.blue : Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _isLocationAlarm = false),
                    child: Text("⏰ Time", style: TextStyle(color: !_isLocationAlarm ? Colors.white : Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLocationAlarm ? Colors.redAccent : Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _isLocationAlarm = true),
                    child: Text("📍 Location", style: TextStyle(color: _isLocationAlarm ? Colors.white : Colors.grey)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- الجزء المتغير (وقت أو موقع) ---
            if (!_isLocationAlarm)
              Center(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: Text(_selectedTime.format(context), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            else
              Center(
                child: InkWell(
                  onTap: _pickLocation, //  تشغيل دالة فتح الخريطة
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: _selectedLatitude == null ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all(color: _selectedLatitude == null ? Colors.redAccent : Colors.green, width: 2)
                    ),
                    child: Column(
                      children: [
                        Icon(_selectedLatitude == null ? Icons.map : Icons.check_circle, color: _selectedLatitude == null ? Colors.redAccent : Colors.green, size: 60),
                        const SizedBox(height: 15),
                        Text(
                          _selectedLatitude == null ? "Tap to pick location on map" : "Location Selected!\nRadius: ${_selectedRadius.toInt()}m",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 40),

            // --- الأجزاء المشتركة ---
            const Text("Repeat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedDays[index] = !_selectedDays[index]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedDays[index] ? Colors.blue : Colors.grey.withOpacity(0.2),
                    ),
                    child: Center(child: Text(_dayNames[index], style: TextStyle(color: _selectedDays[index] ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            
            // مربع الاسم
            TextField(
              controller: _titleController, //  استخدمنا الـ Controller لعدم ضياع النص
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Alarm Name (Optional)", hintStyle: const TextStyle(color: Colors.grey),
                filled: true, fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            
            // النغمات
            SizedBox(
              height: 150, // تحديد ارتفاع لمنع الأخطاء في الـ Scroll
              child: TonesView(
                selectedRingtonePath: _selectedRingtonePath, 
                onChanged: (newPath) => setState(() => _selectedRingtonePath = newPath)
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- زر الحفظ ---
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _saveSmartAlarm, //  تشغيل دالة الحفظ
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Save Alarm", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}