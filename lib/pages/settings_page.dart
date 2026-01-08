import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';
import 'package:squealer/cubit/global_settings_cubit.dart';
import 'package:squealer/pages/viewer_widgets/error_info_widget.dart';
import 'package:squealer/pages/viewer_widgets/loading_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: BlocBuilder<GlobalSettingsCubit, GlobalSettingsState>(
        builder: (context, state) {
          switch (state) {
            case GlobalSettingsInitial():
            case GlobalSettingsLoading():
            case GlobalSettingsFirstTime():
              return LoadingWidget();
            case GlobalSettingsError(:final failure):
              return ErrorInfoWidget(
                errorText: "Error while loading settings",
                failure: failure,
              );
            case GlobalSettingsLoaded(:final settings):
              return ListView(
                shrinkWrap: true,
                children: [
                  ListTileHeading(text: "Browsing settings"),
                  ListTile(
                    title: Text("Row fetch count"),
                    subtitle: Text("Number of rows to fetch at a time"),
                    trailing: SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: settings.rowFetchCount.toString(),
                        keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (value) async {
                          final count = int.tryParse(value);
                          if (count != null && count > 0) {
                            await context
                                .read<GlobalSettingsCubit>()
                                .saveNewRowFetchCount(rowFetchCount: count);
                            if (context.mounted) {
                              await context
                                  .read<GlobalSettingsCubit>()
                                  .loadSettings();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
