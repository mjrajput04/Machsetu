import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/orders/data/order.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Sample pipeline for the Orders screen — delete this line to launch with
  // an empty order history.
  OrderStore.instance.seedDemoOrders();
  runApp(const MachSetuApp());
}

class MachSetuApp extends StatelessWidget {
  const MachSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MachSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        // Keep layout stable regardless of the device font-scale setting.
        final scale = MediaQuery.textScalerOf(context).scale(1).clamp(0.9, 1.2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
    );
  }
}
