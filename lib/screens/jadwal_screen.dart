import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/lokasi_model.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  bool _isLoading = true;
  List<LokasiModel> _kelasList = [];
  int _selectedDay = DateTime.now().weekday; // 1=Monday ... 7=Sunday

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final api = ApiService();
    final list = await api.getLokasi();
    if (mounted) {
      setState(() {
        _kelasList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final List<Color> cardColors = [
      const Color(0xFF003366),
      const Color(0xFFE53935),
      const Color(0xFF28A745),
      const Color(0xFFE67E22),
      const Color(0xFF6C63FF),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF003366), Color(0xFF004080)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jadwal Kuliah', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  // Day selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (i) {
                        int dayNum = i + 1;
                        int date = now.day - (now.weekday - dayNum);
                        bool isSelected = _selectedDay == dayNum;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = dayNum),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(dayNames[i], style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF003366) : Colors.white70, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('$date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF003366) : Colors.white)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jadwal Hari Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 14),
                  _isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Color(0xFF003366))))
                      : Builder(builder: (context) {
                          List<LokasiModel> filteredList = _kelasList.where((k) {
                            if (k.tanggal == null || k.tanggal!.isEmpty) return false;
                            try {
                              DateTime d = DateTime.parse(k.tanggal!);
                              return d.weekday == _selectedDay;
                            } catch(e) {
                              return false;
                            }
                          }).toList();

                          if (filteredList.isEmpty) {
                            return Center(child: Padding(padding: const EdgeInsets.all(30), child: Text('Tidak ada jadwal untuk hari ini', style: TextStyle(color: Colors.grey[400]))));
                          }

                          return Column(
                              children: List.generate(filteredList.length, (i) {
                                final k = filteredList[i];
                                final color = cardColors[i % cardColors.length];
                                String jamMulai = k.jamMulai != null && k.jamMulai!.length >= 5 ? k.jamMulai!.substring(0, 5) : '08:00';
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      // Color indicator
                                      Container(
                                        width: 4,
                                        height: 70,
                                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                                      ),
                                      const SizedBox(width: 12),
                                      // Card
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('${k.namaLokasi} (Pert. ${k.pertemuan ?? 1})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E))),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[400]),
                                                        const SizedBox(width: 4),
                                                        Expanded(child: Text('Radius ${k.radius}m', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(jamMulai, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                        }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
