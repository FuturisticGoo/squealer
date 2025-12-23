import 'package:flutter/material.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/core/routes.dart';

Future<void> main() async {
  await initSetup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Squealer",
      routerConfig: SquealerRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
    );
  }
}
