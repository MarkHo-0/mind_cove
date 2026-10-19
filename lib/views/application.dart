import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/views.dart';

class ApplicationContainer extends StatelessWidget {
  const ApplicationContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: context.read<ViewsProvider>().pageController,
                physics: NeverScrollableScrollPhysics(),
                children: context.read<ViewsProvider>().getViews(),
              ),
            ),
            BottomNavigationBar(
              useLegacyColorScheme: false,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: context.watch<ViewsProvider>().currentIndex,
              onTap: (int index) {
                context.read<ViewsProvider>().changeViewById(index);
              },
              items: context.read<ViewsProvider>().getNavigationItems(),
            ),
          ],
        ),
      ),
    );
  }
}
