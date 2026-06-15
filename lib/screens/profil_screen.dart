import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String _userName = "Mahasiswa";
  String _userNpm = "NPM";
  String _programStudi = "-";
  String _nomorTelpon = "-";
  String _emailMhs = "-";
  String? _fotoProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    
    final api = ApiService();
    final res = await api.getProfil(userId);
    
    if (mounted) {
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          _userName = data['nama'] ?? "Mahasiswa";
          _userNpm = data['npm'] ?? "NPM";
          _programStudi = data['program_studi'] ?? "-";
          _nomorTelpon = data['nomor_telpon'] ?? "-";
          _emailMhs = data['email_mhs'] ?? "-";
          _fotoProfile = data['foto_profile'];
          _isLoading = false;
        });
        prefs.setString('user_name', _userName);
      } else {
        setState(() {
          _userName = prefs.getString('user_name') ?? "Mahasiswa";
          _userNpm = prefs.getString('user_npm') ?? "NPM";
          _isLoading = false;
        });
      }
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: Colors.grey[500]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfilModal() {
    final TextEditingController programStudiCtrl = TextEditingController(text: _programStudi == '-' ? '' : _programStudi);
    final TextEditingController nomorTelponCtrl = TextEditingController(text: _nomorTelpon == '-' ? '' : _nomorTelpon);
    final TextEditingController emailMhsCtrl = TextEditingController(text: _emailMhs == '-' ? '' : _emailMhs);
    File? selectedImage;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setModalState(() {
                  selectedImage = File(pickedFile.path);
                });
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: selectedImage != null 
                              ? FileImage(selectedImage!) 
                              : ((_fotoProfile != null && _fotoProfile!.isNotEmpty)
                                  ? NetworkImage('${Constants.baseUrl.replaceAll('/api', '')}/uploads/profiles/$_fotoProfile') as ImageProvider 
                                  : null),
                            child: (selectedImage == null && (_fotoProfile == null || _fotoProfile!.isEmpty)) 
                                ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Color(0xFF003366), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: programStudiCtrl, decoration: const InputDecoration(labelText: 'Program Studi')),
                    const SizedBox(height: 12),
                    TextField(controller: nomorTelponCtrl, decoration: const InputDecoration(labelText: 'Nomor Telpon'), keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    TextField(controller: emailMhsCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: isSaving ? null : () async {
                          setModalState(() => isSaving = true);
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String userId = prefs.getString('user_id') ?? '';
                          final api = ApiService();
                          final res = await api.updateProfil(userId, programStudiCtrl.text, nomorTelponCtrl.text, emailMhsCtrl.text, selectedImage);
                          
                          if (mounted) {
                            Navigator.pop(ctx);
                            if (res['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diupdate'), backgroundColor: Colors.green));
                              _loadUser();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal update profil'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        child: isSaving 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF003366).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF003366), size: 20),
        ),
        title: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        subtitle: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        color: const Color(0xFF003366),
        child: CustomScrollView(
          slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 30,
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
                children: [
                  const Text('Profil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: (_fotoProfile != null && _fotoProfile!.isNotEmpty)
                              ? NetworkImage('${Constants.baseUrl.replaceAll('/api', '')}/uploads/profiles/$_fotoProfile')
                              : null,
                          child: (_fotoProfile == null || _fotoProfile!.isEmpty)
                              ? Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'M',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                                )
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(_userNpm, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
          ),

          // Info Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF003366)))
                : Column(
                children: [
                  _buildInfoCard(Icons.school_outlined, 'Program Studi', _programStudi),
                  _buildInfoCard(Icons.phone_outlined, 'Nomor Telpon', _nomorTelpon),
                  _buildInfoCard(Icons.email_outlined, 'Email', _emailMhs),
                  const SizedBox(height: 8),

                  // Edit Profil
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF003366).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.edit_outlined, color: Color(0xFF003366), size: 20),
                      ),
                      title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showEditProfilModal,
                    ),
                  ),

                  // Ubah Password
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF003366).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.lock_outline, color: Color(0xFF003366), size: 20),
                      ),
                      title: const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showUbahPasswordDialog,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showUbahPasswordDialog() {
    final TextEditingController passwordLama = TextEditingController();
    final TextEditingController passwordBaru = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordLama,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordBaru,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (passwordLama.text.isEmpty || passwordBaru.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua bidang')));
                      return;
                    }
                    setState(() => isLoading = true);
                    
                    // Call API Ubah Password (implementasi menyusul di backend)
                    await Future.delayed(const Duration(seconds: 1)); // Simulasi
                    
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fungsi ubah password akan segera aktif'), backgroundColor: Colors.orange));
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
