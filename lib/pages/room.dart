import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:partytube_app/model/room.dart';
import 'package:partytube_app/model/user.dart';
import 'package:partytube_app/services/youtube_api.dart';
import 'package:partytube_app/state_management/room_state.dart';
import 'package:partytube_app/state_management/socket_manager.dart';
import 'package:partytube_app/widgets/chat.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> with WidgetsBindingObserver {
  late String roomId;
  late String userId;

  late UserModel user;
  late RoomModel room;

  bool userFound = false;
  bool roomFound = false;

  late SocketManager socketManager;
  late RoomState roomState;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();
  TextEditingController chatController = TextEditingController();

  late BuildContext searchDialog;

  YouTubeApi youTubeApi = YouTubeApi();
  List<Map<String, dynamic>> searchData = [];

  late bool isLoading;

  late StateSetter setSearchDialogState;
  late StateSetter setChatState;

  late YoutubePlayerController youtubePlayerController;

  List<Map<String, String>> chats = [];

  @override
  void initState() {
    super.initState();

    socketManager = context.read<SocketManager>();
    roomState = context.read<RoomState>();

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: '1BfCnjr_Vjg',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    youtubePlayerController.addListener(seekVideo);

    searchController.text = '';
    chatController.text = '';

    isLoading = false;

    setState(() {
      roomId = roomState.getRoomId();
      userId = roomState.getUserId();
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

    socketManager.socketListen("set-videoid", (socketData) {
      youtubePlayerController.load(socketData['videoId']);
      youtubePlayerController.play();

      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);

      scaffold.showSnackBar(SnackBar(
        content: Text('${socketData['username']} changed video'),
      ));
    });

    socketManager.socketListen("receive-message", (dynamic socketData) {
      setChatState(() {
        chats.add({
          "username": socketData['username']['username'],
          "userId": socketData['username']['userId'],
          "message": socketData['username']['message']
        });
      });
    });

    socketManager.socketListen("set-video-duration", (dynamic socketData) {
      List<String> parts = socketData['duration'].split(':');
      if (parts.length != 3) {
        throw const FormatException(
            "Invalid duration format. Expected HH:MM:SS.mmm.");
      }

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      List<String> secondsParts = parts[2].split('.');
      if (secondsParts.length != 2) {
        throw const FormatException(
            "Invalid duration format. Expected HH:MM:SS.mmm.");
      }
      int seconds = int.parse(secondsParts[0]);
      int milliseconds = int.parse(secondsParts[1]);
      Duration position = Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds);

      youtubePlayerController.seekTo(position);

      ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);

      scaffold.showSnackBar(SnackBar(
        content: Text('${socketData['username']} dragged video'),
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
    socketManager.removeListener("set-video");
    socketManager.removeListener("set-videoid");
    socketManager.removeListener("send-message");
    socketManager.removeListener("receive-message");
    socketManager.removeListener("set-video-duration");
    socketManager.removeListener("seek-video");

    youtubePlayerController.dispose();

    chatController.dispose();
    searchController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      handleRoomLeave();
    }

    super.didChangeAppLifecycleState(state);
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

  void searchOnYouTube(bool nextLoad) async {
    setSearchDialogState(() {
      isLoading = true;
    });

    await youTubeApi.search(searchController.text, nextLoad);

    setSearchDialogState(() {
      searchData = youTubeApi.searchResult;

      isLoading = false;
    });
  }

  void handleVideoClick(String videoId) {
    youtubePlayerController.load(videoId);

    socketManager.socketEmit("set-video", {user.name, videoId});

    Navigator.pop(searchDialog);
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          searchDialog = context;
          return StatefulBuilder(builder: (context, setState) {
            setSearchDialogState = setState;

            return AlertDialog(
              title: TextField(
                controller: searchController,
                onSubmitted: (searchQuery) => searchOnYouTube(false),
                decoration: InputDecoration(
                  hintText: 'Search on YouTube',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list_outlined),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'max-result',
                              child: TextField(
                                onChanged: (maxResult) {
                                  int maxValue = int.parse(maxResult);
                                  if (maxValue == 0) {
                                    youTubeApi.searchFilter['maxResults'] = 10;
                                    return;
                                  }
                                  youTubeApi.searchFilter['maxResults'] =
                                      maxValue;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Max Result'),
                              ),
                            ),
                          ]),
                  border: const OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.55,
                child: ListView.builder(
                  itemCount: searchData.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (searchData.isEmpty) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text('Search something'),
                          ),
                        ],
                      );
                    }

                    if (index == searchData.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: isLoading
                              ? LoadingAnimationWidget.waveDots(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  size: 35,
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => searchOnYouTube(true),
                                  child: Text(
                                    'Load More',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                        ),
                      );
                    }

                    double thumbnailWidth =
                        searchData[index]['thumbnailHeight'];
                    double thumbnailHeight =
                        searchData[index]['thumbnailHeight'];
                    String videoTitle = searchData[index]['title'];
                    String imageSrc = searchData[index]['thumbnailUrl'];
                    String videoId = searchData[index]['videoId'];

                    return SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: imageSrc,
                          width: thumbnailWidth,
                          height: thumbnailHeight,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: Text('Loading...'),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(
                          videoTitle,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.clip,
                        ),
                        onTap: () => handleVideoClick(videoId),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(searchDialog);
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            );
          });
        });
  }

  void sendMessage() {
    String message = chatController.text;

    if (message.isEmpty) {
      return;
    }

    socketManager.socketEmit("send-message",
        {"username": user.name, "userId": user.id, "message": message});

    setChatState(() {
      chats.add({"username": user.name, "userId": user.id, "message": message});
    });

    chatController.text = '';
  }

  void seekVideo() {
    if (youtubePlayerController.value.isDragging) {
      socketManager.socketEmit("seek-video", {
        "username": user.name,
        "userId": user.id,
        "duration": youtubePlayerController.value.position.toString()
      });
    }
  }

  youtubePlayer() {
    return SafeArea(
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: youtubePlayerController,
        ),
        builder: (context, player) {
          return player;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientaion) {
      switch (orientaion) {
        case Orientation.portrait:
          return SafeArea(
            child: Builder(builder: (context) {
              if (!userFound && !roomFound) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: LoadingAnimationWidget.prograssiveDots(
                        color: Theme.of(context).primaryColor,
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
                                onPressed: () =>
                                    removeUser(room.users[index].userId),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            iconColor: Colors.red,
                            title: Text(
                              '${room.users[index].username} ${isUserAdmin(room.users[index].userId) ? '(Admin)' : ''}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  appBar: AppBar(
                    title: Text('${room.roomName} (${room.roomId})'),
                    automaticallyImplyLeading: false,
                    leading: Builder(builder: (BuildContext context) {
                      return IconButton(
                        onPressed: handleRoomLeave,
                        icon: const Icon(Icons.arrow_back),
                      );
                    }),
                    actions: [
                      IconButton(
                        onPressed: () => _showSearchDialog(context),
                        icon: const Icon(Icons.search),
                      ),
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState!.openEndDrawer();
                        },
                        icon: const Icon(Icons.menu),
                      ),
                    ],
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      youtubePlayer(),
                      Expanded(
                        child: StatefulBuilder(builder: (context, setState) {
                          setChatState = setState;

                          return ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              String message =
                                  chats[index]['message'] as String;
                              String userSent =
                                  chats[index]['userId'] as String;
                              String username = (user.id == userSent)
                                  ? 'Me'
                                  : chats[index]['username'] as String;

                              return Row(
                                children: [
                                  if (user.id == userSent)
                                    const Spacer(
                                      flex: 1,
                                    ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    child: Chat(
                                      text: message,
                                      username: username,
                                      isMe: username == 'Me',
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        child: TextField(
                          controller: chatController,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            isDense: true,
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(width: 1)),
                            suffixIcon: IconButton(
                              onPressed: () => sendMessage(),
                              icon: const Icon(Icons.send),
                            ),
                          ),
                          onSubmitted: (msg) => sendMessage(),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          );
        case Orientation.landscape:
          return FittedBox(
            fit: BoxFit.contain,
            child: youtubePlayer(),
          );
      }
    });
  }
}
