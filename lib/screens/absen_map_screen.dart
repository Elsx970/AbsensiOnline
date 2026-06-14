import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../models/lokasi_model.dart';
import '../services/location_service.dart';
import 'absen_confirm_screen.dart';

class AbsenMapScreen extends StatefulWidget {
  final String tipe;
  final LokasiModel lokasi;

  const AbsenMapScreen({super.key, required this.tipe, required this.lokasi});

  @override
  State<AbsenMapScreen> createState() => _AbsenMapScreenState();
}

class _AbsenMapScreenState extends State<AbsenMapScreen> {
  Position? _currentPosition;
  double _jarak = 0;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      if (_currentPosition != null) {
        _jarak = LocationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          widget.lokasi.latitude,
          widget.lokasi.longitude,
        );
      }
      setState(() { _isLoading = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _lanjutAmbilFoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (photo != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AbsenConfirmScreen(
              tipe: widget.tipe,
              foto: File(photo.path),
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
              lokasi: widget.lokasi,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka kamera")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Presensi ${widget.tipe}'),
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF003366)),
              SizedBox(height: 20),
              Text('Mendapatkan Titik GPS...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    bool inRadius = _jarak <= widget.lokasi.radius;

    return Scaffold(
      appBar: AppBar(
        title: Text('Presensi ${widget.tipe}'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.absensi',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(widget.lokasi.latitude, widget.lokasi.longitude),
                    color: Colors.blue.withOpacity(0.12),
                    borderColor: const Color(0xFF003366),
                    borderStrokeWidth: 2,
                    radius: widget.lokasi.radius.toDouble(),
                    useRadiusInMeter: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.lokasi.latitude, widget.lokasi.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.school_rounded, color: Color(0xFF003366), size: 30),
                  ),
                  Marker(
                    point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Icon(Icons.my_location, color: Colors.blue, size: 24)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),

                  // Status row
                  Row(
                    children: [
                      const Text('Lokasi Anda Saat Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: inRadius ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(inRadius ? Icons.check_circle : Icons.cancel, size: 14, color: inRadius ? Colors.green : Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              inRadius ? 'Di Dalam Area' : 'Di Luar Area',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: inRadius ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Coords
                  _buildCoordRow(Icons.gps_fixed, 'Latitude', _currentPosition!.latitude.toStringAsFixed(6)),
                  const SizedBox(height: 8),
                  _buildCoordRow(Icons.gps_fixed, 'Longitude', _currentPosition!.longitude.toStringAsFixed(6)),
                  const SizedBox(height: 12),

                  // Radius info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.radar_rounded, size: 18, color: Color(0xFF003366)),
                        const SizedBox(width: 8),
                        Text('Radius Absensi: ${widget.lokasi.radius} Meter', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF003366))),
                        const Spacer(),
                        Text('Jarak: ${_jarak.toStringAsFixed(0)}m', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inRadius ? const Color(0xFF003366) : Colors.grey[400],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: inRadius ? 2 : 0,
                      ),
                      onPressed: inRadius ? _lanjutAmbilFoto : null,
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      label: const Text('LANJUT AMBIL FOTO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      ],
    );
  }
}
