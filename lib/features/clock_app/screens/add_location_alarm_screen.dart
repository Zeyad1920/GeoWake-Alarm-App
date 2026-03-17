import 'package:clock_app/features/clock_app/widgets/build_radius_slider.dart';
import 'package:clock_app/features/clock_app/widgets/save_button_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:clock_app/core/utils/location_helper.dart';

class AddLocationAlarmScreen extends StatefulWidget {
  const AddLocationAlarmScreen({Key? key}) : super(key: key);

  @override
  State<AddLocationAlarmScreen> createState() => _AddLocationAlarmScreenState();
}

class _AddLocationAlarmScreenState extends State<AddLocationAlarmScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(30.0444, 31.2357);
  LatLng? _selectedDestination;
  bool _isLoadingLocation = true;
  double _alarmRadius = 500.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final location = await LocationHelper.getCurrentLocation();
    if (mounted && location != null) {
      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'حدد موقع المنبه',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              onTap: (_, point) => setState(() => _selectedDestination = point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.your_name.clock_app',
              ),
              if (_selectedDestination != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedDestination!,
                      color: Colors.red.withOpacity(0.2),
                      borderStrokeWidth: 2,
                      borderColor: Colors.red,
                      useRadiusInMeter: true,
                      radius: _alarmRadius,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  if (_selectedDestination != null)
                    Marker(
                      point: _selectedDestination!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_selectedDestination != null)
            BuildRadiusSlider(
              alarmRadius: _alarmRadius,
              onChanged: (value) => setState(() => _alarmRadius = value),
            ),
        ],
      ),
      floatingActionButton: _selectedDestination != null
          ? ButtonSaveAction(selectedDestination: _selectedDestination, alarmRadius: _alarmRadius)
          : null,
    );
  }
}