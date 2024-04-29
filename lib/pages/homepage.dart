import 'package:flutter/material.dart';
import 'package:partytube_app/widgets/create_room.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: const Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: Text("Create Room"),
              children: [
                CreateRoom()
              ],
            ),
            ExpansionTile(
              title: Text("Join Room"),
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
