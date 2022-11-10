import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'huawei_share_platform_interface.dart';

/// An implementation of [HuaweiSharePlatform] that uses method channels.
class MethodChannelHuaweiShare extends HuaweiSharePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('huawei_share');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
