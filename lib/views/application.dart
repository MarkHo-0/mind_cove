import 'package:flutter/material.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';

import 'write/write.dart' show WriteView;
import 'calendar/calendar.dart' show CalendarView;
import 'timeline/timeline.dart' show TimelineView;
import 'settings/settings.dart' show SettingsView;

class ApplicationContainer extends StatefulWidget {
  const ApplicationContainer({super.key});

  @override
  State<ApplicationContainer> createState() => _ApplicationContainerState();
}

class _ApplicationContainerState extends State<ApplicationContainer> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    WriteView(),
    TimelineView(),
    CalendarView(),
    SettingsView(),
  ];
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: SafeArea(
          child: Scaffold(
            body: PageView(controller: _pageController, children: _pages),
            bottomNavigationBar: BottomNavigationBar(
              useLegacyColorScheme: false,
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: AppLocalizations.of(context)!.page_write,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timeline),
                  label: AppLocalizations.of(context)!.page_timeline,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: AppLocalizations.of(context)!.page_calendar,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: AppLocalizations.of(context)!.page_settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
