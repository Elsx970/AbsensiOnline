class LokasiModel {
  final String id;
  final String namaLokasi;
  final double latitude;
  final double longitude;
  final int radius;
  final String? tanggal;
  final String? jamMulai;
  final String? jamSelesai;
  final int? pertemuan;

  LokasiModel({
    required this.id,
    required this.namaLokasi,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.tanggal,
    this.jamMulai,
    this.jamSelesai,
    this.pertemuan,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    return LokasiModel(
      id: json['id'].toString(),
      namaLokasi: json['nama_lokasi'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      radius: int.parse(json['radius'].toString()),
      tanggal: json['tanggal'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      pertemuan: json['pertemuan'] != null ? int.tryParse(json['pertemuan'].toString()) : 1,
    );
  }
}
