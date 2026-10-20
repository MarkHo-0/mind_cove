import 'package:material_ui/material_ui.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness);
  final inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
  );
  final focusedInputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    inputDecorationTheme: InputDecorationTheme(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: focusedInputBorder,
    ),
  );
}
