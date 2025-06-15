import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> with AutomaticKeepAliveClientMixin<CalendarView> {
  final List<DateTime?> _values = [];
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          CalendarDatePicker2(config: CalendarDatePicker2Config(), value: _values),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
