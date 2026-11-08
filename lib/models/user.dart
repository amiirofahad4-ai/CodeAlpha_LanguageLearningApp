/// A signed-in learner.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  String get firstName => name.trim().split(' ').first;

  /// Up to two initials for the avatar placeholder.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  AppUser copyWith({String? name, String? avatarUrl}) => AppUser(
    id: id,
    name: name ?? this.name,
    email: email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
  };
}
