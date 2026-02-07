import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/Api/Azkar_API.dart';
import 'package:test_app_new/Notifications/NotificationsService.dart';
import 'package:test_app_new/cubit/azkar_cubit.dart';
import 'package:test_app_new/widgets/Azkar_ListView.dart';
import 'package:test_app_new/widgets/azkarCategori_Screen.dart';
import 'Notifications/azkar_scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

        routes: {
          '/': (context) => AzkarCategoriesScreen(),
          '/azkar': (context) {
            final category =
                ModalRoute.of(context)?.settings.arguments as String? ??
                'أذكار';

            return Scaffold(
              appBar: AppBar(title: Text(category), centerTitle: true),
              body: const AzkarListView(),
            );
          },
        },

        initialRoute: '/',
      ),
    );
  }
}
