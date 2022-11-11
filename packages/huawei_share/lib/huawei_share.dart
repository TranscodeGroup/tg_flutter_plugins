import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HuaweiShare {
  @visibleForTesting
  static const channelName = 'com.transcodegroup/huawei_share';

  static final _instance = HuaweiShare._();
  factory HuaweiShare() => _instance;

  HuaweiShare._();

  final _methodChannel = const MethodChannel(channelName);

  bool? _available = kIsWeb || !Platform.isAndroid //
      ? false
      : null;

  Future<bool> isAvailable() async => _available ??=
      await _methodChannel.invokeMethod<bool>('isAvailable') ?? false;

  Future<void> share({
    String? text,
    String? title,
    String? subject,
    List<String>? paths,
    String? mimeType,
    String? fileProviderAuthority,
  }) =>
      _methodChannel.invokeMethod('share', {
        'text': text,
        'title': title,
        'subject': subject,
        'paths': paths,
        'mimeType': mimeType,
        'fileProviderAuthority': fileProviderAuthority,
      });
}
