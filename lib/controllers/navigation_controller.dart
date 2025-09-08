import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void changeIndex(int index) {
    _currentIndex.value = index;
  }

  void goToHome() {
    _currentIndex.value = 0;
  }

  void goToEvents() {
    _currentIndex.value = 1;
  }

  void goToStats() {
    _currentIndex.value = 2;
  }

  void goToSettings() {
    _currentIndex.value = 3;
  }
}
