import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/views.dart';

class ApplicationContainer extends StatelessWidget {
  const ApplicationContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final views = context.read<ViewsProvider>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final navigationItems = views.getNavigationItems();
            final pageView = PageView(
              controller: views.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: views.getViews(),
            );

            final navigation = isLandscape
                ? NavigationRail(
                    selectedIndex: context.watch<ViewsProvider>().currentIndex,
                    onDestinationSelected: views.changeViewById,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    labelType: NavigationRailLabelType.none,
                    destinations: navigationItems
                        .map(
                          (item) => NavigationRailDestination(
                            icon: item.icon,
                            selectedIcon: item.activeIcon,
                            label: Text(item.label ?? ''),
                          ),
                        )
                        .toList(),
                  )
                : BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    useLegacyColorScheme: false,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    currentIndex: context.watch<ViewsProvider>().currentIndex,
                    onTap: views.changeViewById,
                    items: navigationItems,
                  );

            return Row(
              children: [
                if (isLandscape) navigation,
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: pageView),
                      if (!isLandscape) navigation,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
