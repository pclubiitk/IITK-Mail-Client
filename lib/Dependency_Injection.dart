import 'package:get/get.dart';
import 'network/network_controller.dart';
///this class create the dependency of Networkcontroller
class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(),permanent:true);
  }
}