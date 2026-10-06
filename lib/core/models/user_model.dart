/// User domain model representing user entity in the POT system.
class UserModel {
  final String id;
  final String nama;
  final String username;
  final String email;
  final String role;
  final String? lapakId;
  final String noHp;
  final String status;
  final String authProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.role,
    this.lapakId,
    required this.noHp,
    required this.status,
    required this.authProvider,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  /// Convenient display name resolving to nama, email, or username.
  String get displayName {
    if (nama.trim().isNotEmpty) return nama.trim();
    if (username.trim().isNotEmpty) return username.trim();
    if (email.trim().isNotEmpty) return email.trim();
    return 'Pengguna';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'unassigned',
      lapakId: json['lapak_id'] as String?,
      noHp: json['no_hp'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      authProvider: json['authProvider'] as String? ?? 'password',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'email': email,
      'role': role,
      'lapak_id': lapakId,
      'no_hp': noHp,
      'status': status,
      'authProvider': authProvider,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? username,
    String? email,
    String? role,
    String? lapakId,
    String? noHp,
    String? status,
    String? authProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      lapakId: lapakId ?? this.lapakId,
      noHp: noHp ?? this.noHp,
      status: status ?? this.status,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
