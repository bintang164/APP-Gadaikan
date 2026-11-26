import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Draf pengajuan yang dipertahankan saat pengguna berpindah langkah
/// atau keluar-masuk form. Hanya berisi data non-sensitif; dokumen
/// sensitif tidak disimpan di sini.
class PawnDraft {
  const PawnDraft({
    this.categoryId,
    this.data = const <String, dynamic>{},
  });

  final String? categoryId;
  final Map<String, dynamic> data;

  String? text(String key) => data[key]?.toString();

  List<String> list(String key) {
    final Object? raw = data[key];
    if (raw is List) {
      return raw.map((Object? item) => '$item').toList();
    }
    if (raw is String && raw.isNotEmpty) return raw.split(',');
    return const <String>[];
  }

  PawnDraft copyWith({
    String? categoryId,
    Map<String, dynamic>? data,
  }) {
    return PawnDraft(
      categoryId: categoryId ?? this.categoryId,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'categoryId': categoryId,
        'data': data,
      };

  factory PawnDraft.fromJson(Map<String, dynamic> json) {
    final Object? raw = json['data'];
    return PawnDraft(
      categoryId: json['categoryId'] as String?,
      data: raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{},
    );
  }
}

/// Penyimpanan draf lokal via [SharedPreferences].
class PawnDraftStore {
  static const String draftKey = 'pawn_draft_v1';

  Future<PawnDraft?> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(draftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map) {
        return PawnDraft.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Draf rusak: abaikan, pengguna mulai dari awal.
    }
    return null;
  }

  Future<void> write(PawnDraft draft) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(draftKey, jsonEncode(draft.toJson()));
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(draftKey);
  }
}
