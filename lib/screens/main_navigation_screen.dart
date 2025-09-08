import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'home_screen.dart';
import 'events_list_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'add_event_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.put(NavigationController());

    final List<Widget> screens = [
      const HomeScreen(),
      const EventsListScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: navigationController.currentIndex,
          children: screens,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: navigationController.currentIndex,
          onTap: navigationController.changeIndex,
          onAddPressed: () => _navigateToAddEvent(),
        ),
      );
    });
  }

  void _navigateToAddEvent() {
    Get.to(
      () => const AddEventScreen(),
      transition: Transition.upToDown,
      duration: const Duration(milliseconds: 300),
    );
  }
}
