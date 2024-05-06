import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partytube_app/functions/functions.dart';
import 'package:partytube_app/pages/room.dart';
import 'package:partytube_app/state_management/room_state.dart';
import 'package:partytube_app/state_management/socket_manager.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  TextEditingController username = TextEditingController();
  TextEditingController roomId = TextEditingController();

  String userId = '';

  void handleJoinRoom() {
    if (username.text.isEmpty || roomId.text.isEmpty) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(const SnackBar(
        content: Text('Please enter all fields'),
      ));
    } else {
      String user_id = Functions().getRandomString(8);

      setState(() {
        userId = user_id;
      });

      context
          .read<SocketManager>()
          .socketEmit("join-room", {username.text, user_id, roomId.text});
    }
  }

  @override
  void initState() {
    super.initState();

    username.text = '';
    roomId.text = '';

    context.read<SocketManager>().socketListen("room-not-found", (p0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room not found')),
      );
    });

    context.read<SocketManager>().socketListen("room-found", (p0) {
      context.read<RoomState>().setRoomId(roomId.text);
      context.read<RoomState>().setUserId(userId);

      username.text = '';
      roomId.text = '';

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Room()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          TextField(
            controller: username,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: roomId,
            decoration: const InputDecoration(labelText: 'Room ID'),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 30,
            child: ElevatedButton.icon(
              onPressed: handleJoinRoom,
              label: const Text(
                'Join Room',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.private_connectivity,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
