import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HuaweiShare {
  static final _instance = HuaweiShare._();
  factory HuaweiShare() => _instance;

  HuaweiShare._();

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.transcodegroup/huawei_share');

  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  bool? _available = kIsWeb || !Platform.isAndroid //
      ? false
      : null;

  Future<bool> isAvailable() async => _available ??=
      await methodChannel.invokeMethod<bool>('isAvailable') ?? false;

  Future<void> share({
    String? text,
    String? title,
    String? subject,
    List<String>? paths,
    String? mimeType,
    String? fileProviderAuthority,
  }) =>
      methodChannel.invokeMethod('share', {
        'text': text,
        'title': title,
        'subject': subject,
        'paths': paths,
        'mimeType': mimeType,
        'fileProviderAuthority': fileProviderAuthority,
      });
}
