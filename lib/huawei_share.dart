import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HuaweiShare {
  static final instance = HuaweiShare._();
  HuaweiShare._();

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('huawei_share');

  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
