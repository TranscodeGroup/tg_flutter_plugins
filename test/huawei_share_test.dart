import 'package:flutter_test/flutter_test.dart';
import 'package:huawei_share/huawei_share.dart';
import 'package:huawei_share/huawei_share_platform_interface.dart';
import 'package:huawei_share/huawei_share_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHuaweiSharePlatform
    with MockPlatformInterfaceMixin
    implements HuaweiSharePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HuaweiSharePlatform initialPlatform = HuaweiSharePlatform.instance;

  test('$MethodChannelHuaweiShare is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHuaweiShare>());
  });

  test('getPlatformVersion', () async {
    HuaweiShare huaweiSharePlugin = HuaweiShare();
    MockHuaweiSharePlatform fakePlatform = MockHuaweiSharePlatform();
    HuaweiSharePlatform.instance = fakePlatform;

    expect(await huaweiSharePlugin.getPlatformVersion(), '42');
  });
}
