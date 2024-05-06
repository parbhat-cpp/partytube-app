import 'package:flutter_bloc/flutter_bloc.dart';

class UserRoomInfo {
  late String userId;
  late String roomId;

  UserRoomInfo() {
    roomId = '';
    userId = '';
  }
}

class RoomState extends Cubit<UserRoomInfo> {
  RoomState() : super(UserRoomInfo());

  String getUserId() {
    return state.userId;
  }

  void setUserId(String userId) {
    state.userId = userId;
  }

  String getRoomId() {
    return state.roomId;
  }

  void setRoomId(String roomId) {
    state.roomId = roomId;
  }
}
