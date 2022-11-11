import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huawei_share/huawei_share.dart';

void main() {
  HuaweiShare platform = HuaweiShare();
  const MethodChannel channel = MethodChannel(HuaweiShare.channelName);

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return false;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('isAvailable', () async {
    expect(await platform.isAvailable(), false);
  });
}
