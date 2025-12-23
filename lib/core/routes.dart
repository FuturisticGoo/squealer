import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/pages/home.dart';
import 'package:squealer/pages/viewer.dart';

class SquealerRouter {
  static const homePage = "/home";
  static const viewerPage = "/viewer";
  static const settingsPage = "/settings";
  static final router = GoRouter(
    initialLocation: homePage,
    routes: [
      GoRoute(
        path: homePage,
        builder: (context, state) {
          return HomePage();
        },
      ),
      GoRoute(
        path: viewerPage,
        builder: (context, state) {
          return Viewer(databaseInfo: state.extra as DatabaseInfo);
        },
      ),
      GoRoute(
        path: settingsPage,
        builder: (context, state) {
          return Placeholder();
        },
      ),
    ],
  );
}
