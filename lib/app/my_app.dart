import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:partytube_app/pages/homepage.dart';
import 'package:partytube_app/state_management/room_state.dart';
import 'package:partytube_app/state_management/socket_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Homepage(),
      ),
    );
  }
}
