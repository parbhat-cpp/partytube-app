import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  late SocketManager socketManager;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    socketManager = context.read<SocketManager>();

    setState(() {
      roomId = context.read<RoomState>().getRoomId();
      userId = context.read<RoomState>().getUserId();
    });

    socketManager.socketEmit("get-room", roomId);
    socketManager.socketEmit("get-user", userId);

    socketManager.socketListen("user-info", (userJson) {
      setState(() {
        user = UserModel.fromJson(userJson);
        userFound = true;
      });
    });

    socketManager.socketListen("room-info", (roomJson) {
      setState(() {
        room = RoomModel.fromJson(roomJson);
        roomFound = true;
      });
    });

    socketManager.socketListen("room-not-found", (p0) {
      Navigator.pop(context);
    });

    socketManager.socketListen("user-not-found", (p0) {
      Navigator.pop(context);
    });

    socketManager.socketListen("admin-left-room", (p0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Admin left the room!'),
      ));

      Navigator.pop(context);
    });

    socketManager.socketListen("user-left", (userLeftName) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);

      socketManager.socketEmit("get-room", roomId);

      scaffold.showSnackBar(SnackBar(
        content: Text('$userLeftName left the room!'),
      ));
    });

    socketManager.socketListen("new-user-joined", (username) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);

      socketManager.socketEmit("get-room", roomId);

      scaffold.showSnackBar(SnackBar(
        content: Text('$username joined the room!'),
      ));
    });

    socketManager.socketListen("remove-user-response", (removeUserId) {
      if (userId == removeUserId) {
        socketManager.socketEmit("user-removed", user.name);

        Navigator.pop(context);
      }
    });

    socketManager.socketListen("user-kicked", (username) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);

      socketManager.socketEmit("get-room", roomId);

      scaffold.showSnackBar(SnackBar(
        content: Text('$username was removed by the admin'),
      ));
    });
  }

  @override
  void dispose() {
    socketManager.removeListener("leave-room");
    socketManager.removeListener("user-left");
    socketManager.removeListener("admin-left-room");
    socketManager.removeListener("user-not-found");
    socketManager.removeListener("room-not-found");
    socketManager.removeListener("room-info");
    socketManager.removeListener("user-info");
    socketManager.removeListener("get-user");
    socketManager.removeListener("get-room");
    socketManager.removeListener("new-user-joined");
    socketManager.removeListener("remove-user");
    socketManager.removeListener("remove-user-response");
    socketManager.removeListener("user-removed");
    socketManager.removeListener("user-kicked");

    super.dispose();
  }

  void handleRoomLeave() {
    socketManager.socketEmit("leave-room", {user.id, user.name, user.room});

    Navigator.pop(context);
  }

  bool isUserAdmin(String userId) {
    return room.roomAdminId == userId;
  }

  void removeUser(String userId) {
    socketManager.socketEmit("remove-user", {userId, roomId});
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
                  color: Colors.blue.shade300,
                  size: 75,
                ),
              ),
            ],
          );
        } else {
          return Scaffold(
            key: _scaffoldKey,
            endDrawer: Drawer(
              child: ListView.builder(
                itemCount: room.users.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Visibility(
                        visible: isUserAdmin(userId) &&
                            !isUserAdmin(room.users[index].userId),
                        child: IconButton(
                          tooltip: 'Remove user',
                          onPressed: () => removeUser(room.users[index].userId),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      iconColor: Colors.red,
                      title: Text(
                          '${room.users[index].username} ${isUserAdmin(room.users[index].userId) ? '(Admin)' : ''}'),
                    ),
                  );
                },
              ),
            ),
            appBar: AppBar(
              title: Text('${room.roomName} (${room.roomId})'),
              backgroundColor: Colors.blue.shade300,
              automaticallyImplyLeading: false,
              leading: Builder(builder: (BuildContext context) {
                return IconButton(
                    onPressed: handleRoomLeave,
                    icon: const Icon(Icons.arrow_back));
              }),
              actions: [
                IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: const Icon(Icons.menu),
                ),
              ],
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
