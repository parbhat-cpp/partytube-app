import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:partytube_app/pages/homepage.dart';
import 'package:partytube_app/state_management/room_state.dart';
import 'package:partytube_app/state_management/socket_manager.dart';
import 'package:partytube_app/theme/theme.dart';
import 'package:partytube_app/theme/util.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Retrieves the default theme for the platform
    // TextTheme textTheme = Theme.of(context).textTheme;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme =
        createTextTheme(context, "Albert Sans", "Albert Sans");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiBlocListener(
      listeners: [
        BlocProvider(
          create: (BuildContext context) => SocketManager(),
        ),
        BlocProvider(
          create: (BuildContext context) => RoomState(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        themeMode: ThemeMode.system,
        home: const Homepage(),
      ),
    );
  }
}
