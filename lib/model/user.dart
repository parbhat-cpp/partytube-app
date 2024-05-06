class UserModel {
  final String name;
  final String id;
  final String room;
  final bool isAdmin;

  const UserModel({
    required this.name,
    required this.id,
    required this.isAdmin,
    required this.room
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      id: json['id'] as String,
      isAdmin: json['isAdmin'] as bool,
      room: json['room'] as String
    );
  }
}