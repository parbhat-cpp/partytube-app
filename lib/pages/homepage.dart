import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:partytube_app/state_management/socket_manager.dart';
import 'package:partytube_app/widgets/create_room.dart';
import 'package:partytube_app/widgets/join_room.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late bool loader = false;
  late SocketManager socketManager;

  ExpansionTileController expandCreateRoom = ExpansionTileController();
  ExpansionTileController expandJoinRoom = ExpansionTileController();

  late ThemeData themeData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      themeData = Theme.of(context);

      initSocket();

      loader = false;
    });
  }

  initSocket() {
    setState(() {
      loader = true;
    });

    socketManager = SocketManager();
    socketManager.connect(context);

    setState(() {
      loader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Builder(builder: (context) {
          if (loader) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: LoadingAnimationWidget.prograssiveDots(
                    color: themeData.primaryColor,
                    size: 75,
                  ),
                ),
                const Text('Connecting to server...'),
              ],
            );
          } else {
            return Column(
              children: [
                ExpansionTile(
                  controller: expandCreateRoom,
                  initiallyExpanded: true,
                  title: const Text("Create Room"),
                  children: const [CreateRoom()],
                ),
                ExpansionTile(
                  controller: expandJoinRoom,
                  title: const Text("Join Room"),
                  children: const [JoinRoom()],
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
