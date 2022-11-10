
import 'huawei_share_platform_interface.dart';

class HuaweiShare {
  Future<String?> getPlatformVersion() {
    return HuaweiSharePlatform.instance.getPlatformVersion();
  }
}
