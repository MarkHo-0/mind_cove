import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/views.dart';

class ApplicationContainer extends StatelessWidget {
  const ApplicationContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: context.read<ViewsProvider>().pageController,
          physics: NeverScrollableScrollPhysics(),
          children: context.read<ViewsProvider>().getViews(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          useLegacyColorScheme: false,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: context.watch<ViewsProvider>().currentIndex,
          onTap: (int index) {
            context.read<ViewsProvider>().changeViewById(index);
          },
          items: context.read<ViewsProvider>().getNavigationItems(),
        ),
      ),
    );
  }
}
