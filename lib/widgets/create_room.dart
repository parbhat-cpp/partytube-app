import 'package:flutter/material.dart';
import 'dart:math';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  TextEditingController adminName = TextEditingController();
  TextEditingController roomName = TextEditingController();
  TextEditingController roomId = TextEditingController();

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))),
      );

  @override
  void initState() {
    super.initState();

    adminName.text = "";
    roomName.text = "";
    roomId.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          TextField(
            controller: adminName,
            decoration: const InputDecoration(labelText: "Enter Admin Name"),
          ),
          TextField(
            controller: roomName,
            decoration: const InputDecoration(labelText: "Enter Room Name"),
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 90 / 100 - 45,
                child: TextField(
                  controller: roomId,
                  decoration: const InputDecoration(
                      labelText: "Enter or generate Room ID"),
                ),
              ),
              IconButton(
                onPressed: () {
                  String id = getRandomString(6);
                  setState(() {
                    roomId.text = id;
                  });
                },
                icon: const Icon(Icons.generating_tokens_outlined),
                style: const ButtonStyle(alignment: Alignment.centerRight),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 30,
            child: ElevatedButton.icon(
              onPressed: () {},
              label: Text(
                'Join $roomName',
                style: const TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.private_connectivity,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900),
            ),
          )
        ],
      ),
    );
  }
}
