import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/lokasi_model.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String npm, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/login.php'),
        body: {'npm': npm, 'password': password},
      );
      final data = json.decode(response.body);
      // Menyesuaikan format JSON response login.php -> {'success': bool, 'message': string, 'user': {...}}
      if (data['success'] == true) {
        return {'status': 'success', 'data': data['user']};
      } else {
        return {'status': 'error', 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<List<LokasiModel>> getLokasi() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/lokasi.php'));
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => LokasiModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error getLokasi: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRiwayatHariIni(String userId) async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/riwayat.php?user_id=$userId'));
      final data = json.decode(response.body);
      if (data['success'] == true) {
        String today = DateTime.now().toIso8601String().substring(0, 10);
        List<Map<String, dynamic>> result = [];
        for (var r in (data['data'] as List)) {
          if (r['tanggal'] == today) {
            result.add(Map<String, dynamic>.from(r));
          }
        }
        return result;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> absenMasuk(String userId, String lokasiId, double lat, double lng, File foto) async {
    return _absen(userId, lokasiId, lat, lng, foto, 'masuk');
  }

  Future<Map<String, dynamic>> absenPulang(String userId, String lokasiId, double lat, double lng, File foto) async {
    return _absen(userId, lokasiId, lat, lng, foto, 'pulang');
  }

  Future<Map<String, dynamic>> _absen(String userId, String lokasiId, double lat, double lng, File foto, String jenis) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${Constants.baseUrl}/absen.php'));
      request.fields['user_id'] = userId;
      request.fields['lokasi_id'] = lokasiId;
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = lng.toString();
      request.fields['jenis'] = jenis;
      
      var pic = await http.MultipartFile.fromPath('foto', foto.path);
      request.files.add(pic);
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      
      final data = json.decode(responseString);
      if(data['success'] == true) {
        return {'status': 'success', 'message': data['message']};
      } else {
        return {'status': 'error', 'message': data['message']};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProfil(String userId) async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/profil.php?user_id=$userId'));
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfil(String userId, String programStudi, String nomorTelpon, String emailMhs, File? foto) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${Constants.baseUrl}/update_profil.php'));
      request.fields['user_id'] = userId;
      request.fields['program_studi'] = programStudi;
      request.fields['nomor_telpon'] = nomorTelpon;
      request.fields['email_mhs'] = emailMhs;
      
      if (foto != null) {
        var pic = await http.MultipartFile.fromPath('foto_profile', foto.path);
        request.files.add(pic);
      }
      
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      
      final data = json.decode(responseString);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
