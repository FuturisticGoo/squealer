import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:squealer/core/entities/database_meta_entities.dart';
import 'package:squealer/cubit/global_settings_cubit.dart';
import 'package:squealer/pages/first_time_or_update_page.dart';
import 'package:squealer/pages/home.dart';
import 'package:squealer/pages/settings_page.dart';
import 'package:squealer/pages/viewer.dart';

class SquealerRouter {
  static const firstTimeOrUpdatePage = "/first_time_or_update";
  static const homePage = "/home";
  static const viewerPage = "/viewer";
  static const settingsPage = "/settings";
  static final GoRouter router = GoRouter(
    initialLocation: firstTimeOrUpdatePage,
    onEnter: (context, currentState, nextState, goRouter) {
      if (nextState.uri.scheme == "content") {
        Loggify.getLogger?.config("Opening content URI: ${nextState.uri}");
        goRouter.go(homePage, extra: nextState.uri);
        return Block.stop();
      } else {
        Loggify.getLogger?.config("Not a content URI: ${nextState.uri}");
        return Allow();
      }
    },
    redirect: (context, state) {
      final settingsState = context.read<GlobalSettingsCubit>().state;
      if (settingsState is GlobalSettingsFirstTime ||
          (settingsState is GlobalSettingsLoaded &&
              settingsState.metadata.isUpdated)) {
        Loggify.getLogger?.fine("Redirecting to first time or update page");
        return firstTimeOrUpdatePage;
      } else {
        return null;
      }
    },
    routes: [
      GoRoute(
        path: firstTimeOrUpdatePage,
        builder: (context, state) {
          Loggify.getLogger?.fine("Going to FirstTimeOrUpdatePage");
          return FirstTimeOrUpdatePage();
        },
      ),
      GoRoute(
        path: homePage,
        builder: (context, state) {
          Loggify.getLogger?.fine("Going to HomePage(${state.extra})");
          return HomePage(databaseContentUri: state.extra as Uri?);
        },
      ),
      GoRoute(
        path: viewerPage,
        builder: (context, state) {
          Loggify.getLogger?.fine("Going to Viewer(${state.extra})");
          return Viewer(databaseInfo: state.extra as DatabaseInfo);
        },
      ),
      GoRoute(
        path: settingsPage,
        builder: (context, state) {
          Loggify.getLogger?.fine("Going to SettingsPage");
          return SettingsPage();
        },
      ),
    ],
  );
}
