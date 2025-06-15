import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mind_cove/views/application.dart' show ApplicationContainer;
import 'l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/settings.dart';
import 'providers/views.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<ViewsProvider>(create: (_) => ViewsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final brightness = settings.brightness ?? MediaQuery.platformBrightnessOf(context);
    final locale = Locale(settings.languageCode);

    return MaterialApp(
      title: 'Mind Cove',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, brightness: brightness),
      home: ApplicationContainer(),
      scrollBehavior: scrollBehaviorFixed,
      locale: locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
    );
  }

  ScrollBehavior get scrollBehaviorFixed {
    if (Platform.isAndroid || Platform.isIOS) return const MaterialScrollBehavior();

    return const MaterialScrollBehavior().copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
    );
  }
}
