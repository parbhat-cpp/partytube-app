import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:partytube_app/model/room.dart';
import 'package:partytube_app/model/user.dart';
import 'package:partytube_app/state_management/room_state.dart';
import 'package:partytube_app/state_management/socket_manager.dart';

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  late String roomId;
  late String userId;

  late UserModel user;
  late RoomModel room;

  bool userFound = false;
  bool roomFound = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      roomId = context.read<RoomState>().getRoomId();
      userId = context.read<RoomState>().getUserId();
    });

    context.read<SocketManager>().socketEmit("get-room", roomId);
    context.read<SocketManager>().socketEmit("get-user", userId);

    context.read<SocketManager>().socketListen("user-info", (userJson) {
      setState(() {
        user = UserModel.fromJson(userJson);
        userFound = true;
      });
    });

    context.read<SocketManager>().socketListen("room-info", (roomJson) {
      setState(() {
        room = RoomModel.fromJson(roomJson);
        roomFound = true;
      });
    });

    context.read<SocketManager>().socketListen("room-not-found", (userJson) {
      Navigator.of(context).pop();
    });

    context.read<SocketManager>().socketListen("user-not-found", (p0) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(builder: (context) {
        if (!userFound && !roomFound) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: LoadingAnimationWidget.prograssiveDots(
                  color: Colors.black26,
                  size: 75,
                ),
              ),
            ],
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('${room.roomName} (${room.roomId})'),
              backgroundColor: Colors.black,
            ),
            body: Column(
              children: [
                Text('${room.roomAdminId} ${room.roomAdminUsername}'),
              ],
            ),
          );
        }
      }),
    );
  }
}
