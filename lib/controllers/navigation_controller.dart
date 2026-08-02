import 'package:get/get.dart';
import '../screens/welcome_page.dart';

class NavigationController extends GetxController {
  void goToWelcome() {
    Get.offAll(() => const WelcomePage());
    // OR with named routes:
    // Get.offAllNamed('/welcome');
  }

  void goToHome() {
    Get.offAllNamed('/home');
  }
}
