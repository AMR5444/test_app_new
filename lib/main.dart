import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:test_app_new/views/main_navigation_screen.dart';
import 'package:test_app_new/azkr_section/logic/azkar_cubit.dart';
import 'package:test_app_new/azkr_section/views/azkarCategori_Screen.dart';
import 'package:test_app_new/core/Notifications/NotificationsService.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCubit(AzkarApi()),
      child: MaterialApp(
        navigatorKey: NotificationsService.navigatorKey,
        debugShowCheckedModeBanner: false,

        home: const MainNavigationScreen(),

        routes: {
          '/azkar': (context) {
            final category =
                ModalRoute.of(context)?.settings.arguments as String? ??
                'أذكار';

            return Scaffold(
              appBar: AppBar(title: Text(category), centerTitle: true),
              body: AzkarCategoriesScreen(), //
            );
          },
        },
      ),
    );
  }
}
