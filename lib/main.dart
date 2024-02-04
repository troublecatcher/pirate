import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:pirate/economics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/router.dart';

final locator = GetIt.instance;
var creditBalance;

Future<void> main() async {
  await init();
  runApp(MainApp());
}

init() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  // locator<SharedPreferences>().clear();
  if (locator<SharedPreferences>().getInt('credits') == null) {
    await locator<SharedPreferences>().setInt('credits', initialBalance);
    await locator<SharedPreferences>()
        .setInt('rewardCooldown', DateTime.now().millisecondsSinceEpoch);
    await locator<SharedPreferences>().setBool('vibro', true);
    await locator<SharedPreferences>().setInt('preferredIconIndex', 0);
  }
  creditBalance = ValueNotifier<int>(
    locator<SharedPreferences>().getInt('credits')!,
  );
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        ScreenUtil.init(context);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter.config(),
        );
      },
    );
  }
}
