import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await session.restore();
  runApp(const CampusMoveApp());
}

class CampusMoveApp extends StatelessWidget {
  const CampusMoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusMove',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0B7A75),
      ),
      home: AnimatedBuilder(
        animation: session,
        builder: (context, _) =>
            session.user == null ? const LoginScreen() : const MainShell(),
      ),
    );
  }
}