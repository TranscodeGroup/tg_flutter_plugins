import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:huawei_share/huawei_share.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

late final PackageInfo _packageInfo;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _packageInfo = await PackageInfo.fromPlatform();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final _huaweiShare = HuaweiShare();
  static final _imagePicker = ImagePicker();

  late final available = _huaweiShare.isAvailable();
  XFile? _file;
  void _onSharePressed({bool forceUseAndroidShare = false}) async {
    const text = 'fuck';
    if (!forceUseAndroidShare && !kIsWeb && Platform.isAndroid) {
      _huaweiShare.share(
          text: text,
          title: 'title',
          subject: 'subject',
          paths: _file != null ? [_file!.path] : null,
          mimeType: _file != null ? 'image/*' : null,
          // Using the image_provider plugin's FileProvider
          fileProviderAuthority:
              '${_packageInfo.packageName}.flutter.image_provider');
    } else {
      unawaited(_file == null
          ? Share.share(text)
          : Share.shareXFiles([_file!], text: text));
    }
  }

  void _onPickFilePressed() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: available,
                builder: (context, s) => Text('Huawei Share: ${s.data}'),
              ),
              TextButton(
                onPressed: _onPickFilePressed,
                child: Text('file: ${_file?.path}'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _onSharePressed,
                    child: const Text('Huawei Share'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        _onSharePressed(forceUseAndroidShare: true),
                    child: const Text('Android Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
