class User {
  String userId;
  String username;

  User({required this.userId, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'] as String, username: json['username'] as String);
  }
}

class RoomModel {
  final String roomName;
  final String roomId;
  final String roomAdminUsername;
  final String roomAdminId;
  final List<User> users;

  RoomModel(
      {required this.roomAdminId,
      required this.roomAdminUsername,
      required this.roomId,
      required this.roomName,
      required this.users});

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<User> usersList = <User>[];

    for (int i = 0; i < json['users'].length; i++) {
      usersList.add(User.fromJson(json['users'][i]));
    }

    return RoomModel(
        roomAdminId: json['roomAdminId'] as String,
        roomAdminUsername: json['roomAdminUsername'] as String,
        roomId: json['roomId'] as String,
        roomName: json['roomName'] as String,
        users: usersList);
  }
}
