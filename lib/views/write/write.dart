import 'package:flutter/material.dart';

class WriteView extends StatefulWidget {
  const WriteView({super.key});

  @override
  State<WriteView> createState() => _WriteViewState();
}

class _WriteViewState extends State<WriteView> with AutomaticKeepAliveClientMixin<WriteView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: Center(child: Text('Welcome to the Write View!')));
  }

  @override
  bool get wantKeepAlive => true;
}
