import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:huawei_share/huawei_share.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _huaweiShare = HuaweiShare();

  late final platformVersion = _huaweiShare.getPlatformVersion();
  late final available = _huaweiShare.isAvailable();

  void _onSharePressed() {
    _huaweiShare.share(
      text: 'fuck',
      title: 'title',
      subject: 'subject',
    );
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
                future: platformVersion,
                builder: (context, s) => Text('Running on: ${s.data}'),
              ),
              FutureBuilder(
                future: available,
                builder: (context, s) => Text('Huawei Share: ${s.data}'),
              ),
              OutlinedButton(
                onPressed: _onSharePressed,
                child: const Text('share'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
