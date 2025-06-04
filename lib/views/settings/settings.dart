import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with AutomaticKeepAliveClientMixin<SettingsView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: Center(child: Text('Welcome to the Settings View!')));
  }

  @override
  bool get wantKeepAlive => true;
}
