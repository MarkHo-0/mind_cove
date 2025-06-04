import 'package:flutter/material.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> with AutomaticKeepAliveClientMixin<TimelineView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: Center(child: Text('Welcome to the Timeline View!')));
  }

  @override
  bool get wantKeepAlive => true;
}
