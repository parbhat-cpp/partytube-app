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

    context.read<SocketManager>().socketListen("room-not-found", (p0) {
      Navigator.of(context).pop(context);
    });

    context.read<SocketManager>().socketListen("user-not-found", (p0) {
      Navigator.of(context).pop(context);
    });

    context.read<SocketManager>().socketListen("admin-left-room", (p0) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(const SnackBar(
        content: Text('Admin left the room!'),
      ));

      Navigator.of(context).pop(context);
    });
  }

  @override
  void dispose() {
    super.dispose();

    context.read<SocketManager>().removeListener("leave-room");
    context.read<SocketManager>().removeListener("admin-left-room");
    context.read<SocketManager>().removeListener("user-not-found");
    context.read<SocketManager>().removeListener("room-not-found");
    context.read<SocketManager>().removeListener("room-info");
    context.read<SocketManager>().removeListener("user-info");
    context.read<SocketManager>().removeListener("get-user");
    context.read<SocketManager>().removeListener("get-room");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void handleRoomLeave() {
    context
        .read<SocketManager>()
        .socketEmit("leave-room", {user.id, user.name, user.room});

    Navigator.of(context).pop(context);
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
              automaticallyImplyLeading: false,
              leading: Builder(builder: (BuildContext context) {
                return IconButton(
                    onPressed: handleRoomLeave,
                    icon: const Icon(Icons.arrow_back));
              }),
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
