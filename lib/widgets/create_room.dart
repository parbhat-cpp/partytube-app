import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partytube_app/functions/functions.dart';
import 'package:partytube_app/pages/room.dart';
import 'package:partytube_app/state_management/room_state.dart';
import 'package:partytube_app/state_management/socket_manager.dart';
import 'package:share_plus/share_plus.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  TextEditingController adminName = TextEditingController();
  TextEditingController roomName = TextEditingController();
  TextEditingController roomId = TextEditingController();

  String userId = '';

  Future<void> handleJoinRoom(BuildContext context) async {
    if (adminName.text.isEmpty ||
        roomName.text.isEmpty ||
        roomId.text.isEmpty) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(const SnackBar(
        content: Text('Please enter all fields'),
      ));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Create ${roomName.text}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: roomId,
                    onChanged: (value) {
                      setState(() {
                        roomId.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      label: const Text('Room ID'),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: roomId.text));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Share.share(roomId.text,
                          subject:
                              'Hey! Lets connect on Party Tube and watch something interesting together.');
                    },
                    label: const Text('Share room id'),
                    icon: const Icon(Icons.share),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: handleCreateAndJoinRoom,
                    label: const Text('Create Room & Join'),
                    icon: const Icon(Icons.private_connectivity),
                  ),
                ],
              ),
            );
          });
    }
  }

  void handleCreateAndJoinRoom() {
    String admin_name = adminName.text;
    String room_name = roomName.text;
    String room_id = roomId.text;
    String user_id = Functions().getRandomString(8);

    setState(() {
      userId = user_id;
    });

    context
        .read<SocketManager>()
        .socketEmit("create-room", {admin_name, user_id, room_name, room_id});
  }

  @override
  void initState() {
    super.initState();

    adminName.text = "";
    roomName.text = "";
    roomId.text = "";

    context.read<SocketManager>().socketListen("room-exists", (p0) {
      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(const SnackBar(
        content: Text('Room exists with this ID'),
      ));
    });

    context.read<SocketManager>().socketListen("room-n-exists", (p0) {
      context.read<RoomState>().setRoomId(roomId.text);
      context.read<RoomState>().setUserId(userId);

      adminName.text = '';
      roomName.text = '';
      roomId.text = '';

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Room()));
    });
  }

  @override
  void dispose() {
    context.read<SocketManager>().removeListener("room-n-exists");
    context.read<SocketManager>().removeListener("room-exists");
    context.read<SocketManager>().removeListener("create-room");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          TextField(
            controller: adminName,
            onChanged: (enteredAdminName) {
              adminName.text = enteredAdminName;
            },
            decoration: const InputDecoration(labelText: "Enter Admin Name"),
          ),
          TextField(
            controller: roomName,
            onChanged: (enteredRoomName) {
              setState(() {
                roomName.text = enteredRoomName;
              });
            },
            decoration: const InputDecoration(labelText: "Enter Room Name"),
          ),
          TextField(
            controller: roomId,
            decoration: InputDecoration(
              labelText: "Enter or generate Room ID",
              suffixIcon: IconButton(
                onPressed: () {
                  String id = Functions().getRandomString(6);
                  setState(() {
                    roomId.text = id;
                  });
                },
                icon: const Icon(Icons.generating_tokens_outlined),
                style: const ButtonStyle(alignment: Alignment.centerRight),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 30,
            child: ElevatedButton.icon(
              onPressed: () => handleJoinRoom(context),
              label: Text(
                'Create ${roomName.text}',
                style: const TextStyle(color: Colors.white),
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
