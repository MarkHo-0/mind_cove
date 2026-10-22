import 'package:material_ui/material_ui.dart';

class AppRestart extends StatefulWidget {
  final Widget child;

  const AppRestart({required this.child, super.key});

  static void restart(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppRestartState>();
    if (state == null) {
      throw StateError('AppRestart must be an ancestor of the calling context');
    }
    state.restart();
  }

  @override
  State<AppRestart> createState() => _AppRestartState();
}

class _AppRestartState extends State<AppRestart> {
  Key _subtreeKey = UniqueKey();

  void restart() {
    setState(() => _subtreeKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _subtreeKey, child: widget.child);
  }
}
