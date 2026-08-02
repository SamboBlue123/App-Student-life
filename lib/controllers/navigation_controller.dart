import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/welcome_page.dart';

class NavigationController extends GetxController {
  void goToLogin() {
    Get.to(() => const LoginScreen());
    // OR with named routes:
    // Get.toNamed('/login');
  }

  void goToWelcome() {
    Get.offAll(() => const WelcomePage());
    // OR with named routes:
    // Get.offAllNamed('/welcome');
  }

  void goToHome() {
    Get.offAllNamed('/home');
  }
}