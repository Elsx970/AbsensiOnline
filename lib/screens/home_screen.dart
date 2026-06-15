import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'absen_map_screen.dart';
import '../services/api_service.dart';
import '../models/lokasi_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "Mahasiswa";
  String _userNpm = "NPM";
  bool _isLoading = true;
  List<LokasiModel> _kelasList = [];
  List<Map<String, dynamic>> _riwayatHariIni = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadKelas();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Mahasiswa";
      _userNpm = prefs.getString('user_npm') ?? "NPM";
    });
  }

  Future<void> _loadKelas() async {
    final api = ApiService();
    final list = await api.getLokasi();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    final riwayat = await api.getRiwayatHariIni(userId);

    if (mounted) {
      setState(() {
        _kelasList = list;
        _riwayatHariIni = riwayat;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: _loadKelas,
        color: const Color(0xFF003366),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Blue Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 24,
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
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('UNILA Attendance', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Greeting
                    Text('Halo,', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85))),
                    Text(
                      _userName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    // NPM badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('NPM $_userNpm', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Mata Kuliah Hari Ini
                    _buildSectionTitle('MATA KULIAH HARI INI'),
                    const SizedBox(height: 12),

                    _isLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Color(0xFF003366))))
                        : _kelasList.isEmpty
                            ? _buildEmptyState()
                            : Column(children: _kelasList.map((k) => _buildKelasCard(k)).toList()),

                    const SizedBox(height: 24),

                    // Section: Status Kehadiran
                    _buildSectionTitle('STATUS KEHADIRAN'),
                    const SizedBox(height: 12),
                    _buildStatusCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF003366), letterSpacing: 0.5));
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, color: Colors.grey[300], size: 48),
          const SizedBox(height: 12),
          Text('Tidak ada kelas hari ini', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildKelasCard(LokasiModel kelas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showAbsenBottomSheet(kelas);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${kelas.namaLokasi} (Pert. ${kelas.pertemuan ?? 1})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time_rounded, '${kelas.jamMulai != null && kelas.jamMulai!.length >= 5 ? kelas.jamMulai!.substring(0, 5) : '08:00'} - ${kelas.jamSelesai != null && kelas.jamSelesai!.length >= 5 ? kelas.jamSelesai!.substring(0, 5) : '09:40'} WIB', const Color(0xFF003366)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildInfoChip(Icons.location_on_rounded, 'Radius: ${kelas.radius}m', Colors.green),
                  ],
                ),
                Builder(builder: (context) {
                  var riwayatKelas = _riwayatHariIni.where((r) => r['lokasi_id'].toString() == kelas.id).toList();
                  if (riwayatKelas.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          const Text('Selesai (Sudah Absen)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatusCard() {
    double percentage = 1.0;
    if (_kelasList.isNotEmpty) {
      percentage = _riwayatHariIni.length / _kelasList.length;
    } else {
      percentage = 1.0; // If no class today, technically attendance is 100% or N/A
    }
    
    if (percentage > 1.0) percentage = 1.0; // Safeguard

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Kehadiran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text('Hari Ini', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          // Circular progress
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
               alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF003366)),
                  ),
                ),
                Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbsenBottomSheet(LokasiModel kelas) {
    var riwayatKelas = _riwayatHariIni.where((r) => r['lokasi_id'].toString() == kelas.id).toList();
    bool sudahMasuk = riwayatKelas.isNotEmpty;

    DateTime now = DateTime.now();
    bool isDiluarJam = false;
    String pesanDiluarJam = "";

    if (kelas.tanggal != null && kelas.tanggal != now.toIso8601String().substring(0, 10)) {
      isDiluarJam = true;
      pesanDiluarJam = "Bukan tanggal kelas hari ini";
    } else if (kelas.jamSelesai != null && kelas.jamSelesai!.contains(':')) {
      try {
        List<String> parts = kelas.jamSelesai!.split(':');
        DateTime kelasSelesai = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
        if (now.isAfter(kelasSelesai)) {
          isDiluarJam = true;
          pesanDiluarJam = "Waktu kelas sudah berakhir";
        }
      } catch (e) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('${kelas.namaLokasi} (Pertemuan ${kelas.pertemuan ?? 1})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 6),
              Text('Radius: ${kelas.radius} Meter', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 24),
              
              if (sudahMasuk)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text('Anda sudah menyelesaikan presensi kelas ini', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  ),
                )
              else if (isDiluarJam)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(pesanDiluarJam, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28A745),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AbsenMapScreen(tipe: 'Masuk', lokasi: kelas)));
                    },
                    icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                    label: const Text('Absen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
