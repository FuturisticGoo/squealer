import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:squealer/core/init_setup.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/global_settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSetup();
  runApp(const SquealerApp());
}

class SquealerApp extends StatelessWidget {
  const SquealerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return BlocProvider(
          create: (context) => GlobalSettingsCubit(settingsRepo: sl()),
          child: MaterialApp.router(
            title: "Squealer",
            routerConfig: SquealerRouter.router,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightDynamic,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic,
              brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.system,
          ),
        );
      },
    );
  }
}
