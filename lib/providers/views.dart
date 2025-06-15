import 'package:flutter/material.dart';

import '../views/calendar/calendar.dart' show CalendarView;
import '../views/settings/settings.dart' show SettingsView;
import '../views/timeline/timeline.dart' show TimelineView;
import '../views/write/write.dart' show WriteView;

class ViewsProvider extends ChangeNotifier {
  final PageController _pageController = PageController(initialPage: 0);
  ViewType _currentView = ViewType.write;

  void changeView(ViewType view) {
    _currentView = view;
    _pageController.jumpToPage(view.id);
    notifyListeners();
  }

  void changeViewById(int id) {
    if (id < 0 || id >= ViewType.values.length) {
      throw ArgumentError('Invalid view ID: $id');
    }

    _currentView = ViewType.values[id];
    _pageController.jumpToPage(id);
    notifyListeners();
  }

  PageController get pageController => _pageController;

  List<Widget> getViews() {
    return [WriteView(), TimelineView(), CalendarView(), SettingsView()];
  }

  List<BottomNavigationBarItem> getNavigationItems() {
    final List<IconData> icons = [Icons.edit, Icons.timeline, Icons.calendar_today, Icons.settings];

    return icons.map((icon) {
      return BottomNavigationBarItem(icon: Icon(icon), label: '');
    }).toList();
  }

  int get currentIndex => _currentView.id;
}

enum ViewType {
  write(0),
  timeline(1),
  calendar(2),
  settings(3);

  final int id;
  const ViewType(this.id);
}
