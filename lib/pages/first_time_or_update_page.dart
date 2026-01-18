import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:squealer/core/constants.dart';
import 'package:squealer/core/routes.dart';
import 'package:squealer/cubit/global_settings_cubit.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/loading_widget.dart';

class FirstTimeOrUpdatePage extends StatefulWidget {
  const FirstTimeOrUpdatePage({super.key});

  @override
  State<FirstTimeOrUpdatePage> createState() => _FirstTimeOrUpdatePageState();
}

class _FirstTimeOrUpdatePageState extends State<FirstTimeOrUpdatePage> {
  bool firstTimeCallbackRegistered = false;
  bool updateCallbackRegistered = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocBuilder<GlobalSettingsCubit, GlobalSettingsState>(
        builder: (context, state) {
          switch (state) {
            case GlobalSettingsInitial():
            case GlobalSettingsLoading():
              return Center(child: CircularProgressIndicator());
            case GlobalSettingsFirstTime():
              // If it's the first time the user is using this app, add all the
              // default settings and stuff
              if (!firstTimeCallbackRegistered) {
                firstTimeCallbackRegistered = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await context
                      .read<GlobalSettingsCubit>()
                      .saveNewRowFetchCount(
                        rowFetchCount: defaultRowFetchCount,
                      );
                  if (context.mounted) {
                    await context
                        .read<GlobalSettingsCubit>()
                        .updateLastUsedVersion(newVersion: appVersion);
                  }
                  if (context.mounted) {
                    await context.read<GlobalSettingsCubit>().loadSettings();
                  }
                  if (context.mounted) {
                    context.go(SquealerRouter.homePage);
                  }
                });
              }
              return LoadingWidget(loadingText: "Settings up everything...");
            case GlobalSettingsLoaded():
              // When the app is updated.
              // Nothing to do as of now, but may be required later.
              if (!updateCallbackRegistered) {
                updateCallbackRegistered = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (context.mounted) {
                    await context
                        .read<GlobalSettingsCubit>()
                        .updateLastUsedVersion(newVersion: appVersion);
                  }
                  if (context.mounted) {
                    await context.read<GlobalSettingsCubit>().loadSettings();
                  }
                  if (context.mounted) {
                    context.go(SquealerRouter.homePage);
                  }
                });
              }
              return LoadingWidget(loadingText: "Updating app..");
            case GlobalSettingsError(:final failure):
              return ErrorInfoWidget(
                errorText: "Error while loading settings",
                failure: failure,
              );
          }
        },
      ),
    );
  }
}
