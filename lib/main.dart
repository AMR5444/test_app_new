import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:test_app_new/views/main_navigation_screen.dart';
import 'package:test_app_new/azkr_section/logic/azkar_cubit.dart';
import 'package:test_app_new/azkr_section/views/azkarCategori_Screen.dart';
import 'package:test_app_new/core/Notifications/NotificationsService.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'azkr_section/data/Azkar_API.dart';
import 'core/Notifications/azkar_scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('favoritesBox');
  await Hive.openBox('tafsirBox');
  await Hive.openBox('lastPositionBox');
  await Hive.openBox('bookmarksBox');
  await Hive.openBox('notesBox');

  await requestNotificationPermission();
  await scheduleDailyAzkar();
  await QcfFontLoader.setupFontsAtStartup(onProgress: (double progress) {});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AzkarCubit(AzkarApi())),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            navigatorKey: NotificationsService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'نور',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigationScreen(),
            routes: {
              '/azkar': (context) {
                final category =
                    ModalRoute.of(context)?.settings.arguments as String? ??
                    'أذكار';
                return Scaffold(
                  appBar: AppBar(title: Text(category), centerTitle: true),
                  body: AzkarCategoriesScreen(),
                );
              },
            },
          );
        },
      ),
    );
  }
}
