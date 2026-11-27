/// Authenticated user returned by `GET /api/auth/me`.
class UserModel {
  const UserModel({
    required this.id,
    this.name,
    this.email,
  });

  final String id;
  final String? name;
  final String? email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: json['name'] as String? ?? json['Name'] as String?,
      email: json['email'] as String? ?? json['Email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
