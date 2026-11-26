/// Data pengguna yang sedang masuk.
///
/// Model ini sengaja tidak menyimpan kata sandi. Token autentikasi
/// disimpan terpisah di [SessionStore] (secure storage).
class AuthUser {
  final String id;
  final String name;
  final String phone;
  final String? email;

  /// True jika akun berasal dari mode demo lokal, bukan backend Laravel.
  final bool isDemo;

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.isDemo = false,
  });

  String get safeName {
    final String trimmed = name.trim();
    return trimmed.isEmpty ? 'Pengguna Gadaikan' : trimmed;
  }

  /// Inisial untuk avatar, misalnya "Siti Rahma" menjadi "SR".
  String get initials {
    final List<String> parts = safeName
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    bool? isDemo,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final Object? rawEmail = json['email'];
    final Object? rawPhone = json['phone'] ?? json['phone_number'];
    return AuthUser(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      phone: rawPhone == null ? '' : '$rawPhone',
      email: rawEmail == null ? null : '$rawEmail',
      isDemo: json['is_demo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'is_demo': isDemo,
    };
  }
}
