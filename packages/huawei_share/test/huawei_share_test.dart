import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huawei_share/huawei_share.dart';

void main() {
  HuaweiShare platform = HuaweiShare();
  const MethodChannel channel = MethodChannel(HuaweiShare.channelName);

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return false;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isAvailable', () async {
    expect(await platform.isAvailable(), false);
  });
}
