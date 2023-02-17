import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:characters/characters.dart';
import 'package:excel/excel.dart';

void main(List<String> args) async {
  final list = await excelToJson();

  final provinceMap = getProvince(list[1]);
  await saveToFile(
    provinceMap,
    field: 'Map<String, String> thProvincesData',
    fileName: 'province',
  );

  final districtMap = getDistrict(list[1], list[2]);
  await saveToFile(
    districtMap,
    field: 'Map<String, dynamic> thCitiesData',
    fieldGeneric: '<String, Map<String, Map<String, String>>>',
    fileName: 'district',
  );

  await Process.run('dart', ['format', 'lib']);
  await Process.run('dart', ['fix', '--apply']);
}

/// 保存到文件
Future<void> saveToFile(
  Object object, {
  required String field,
  String fieldGeneric = '',
  required String fileName,
}) async {
  print('开始执行写入文件');
  try {
    final jsonFile = File('lib/src/$fileName.dart');

    //判断文件是否存在
    if (!await jsonFile.exists()) {
      await jsonFile.create();
      print('文件创建成功');
    } else {
      print('文件已存在');
    }

    //写入的数据
    final contents = JsonEncoder.withIndent('  ').convert(object);

    // json文件写入
    await jsonFile.writeAsString(
      '''/// Generate by xxx, DO NOT EDIT IT
const $field = $fieldGeneric$contents;
''',
      flush: true,
    );

    print('执行写入文件成功');
  } catch (e) {
    print('执行写入文件失败');
  }
}

/// 生成行政区划之县的json
Map<String, Map<String, Map<String, String>>> getDistrict(
  List<Map<String, String>> provinceList,
  List<Map<String, String>> districtList,
) {
  final map =
      SplayTreeMap<String, Map<String, Map<String, String>>>((key1, key2) {
    return key1.compareTo(key2);
  });

  for (final province in provinceList) {
    final provinceCode = province['ADM1_PCODE'] ?? '';

    final kMap = SplayTreeMap<String, Map<String, String>>((key1, key2) {
      return key1.compareTo(key2);
    });

    for (final district in districtList) {
      final name = district['ADM2_TH'] ?? '';
      final code = district['ADM2_PCODE'] ?? '';

      if (provinceCode == district['ADM1_PCODE']) {
        final mMap = <String, String>{};
        final mMapEntry = <String, String>{
          'name': name,
          'alpha': name.characters.first
        };
        mMap.addEntries(mMapEntry.entries);

        final kMapEntry = <String, Map<String, String>>{code: mMap};
        kMap.addEntries(kMapEntry.entries);
      }
    }

    final mapEntry = <String, Map<String, Map<String, String>>>{
      provinceCode: kMap,
    };
    map.addEntries(mapEntry.entries);
  }

  return map;
}

/// 生成行政区划之府的json
Map<String, String> getProvince(List<Map<String, String>> provinceList) {
  final map = SplayTreeMap<String, String>((key1, key2) {
    return key1.compareTo(key2);
  });

  for (final province in provinceList) {
    final key = province['ADM1_PCODE'] ?? '';
    final value = province['ADM1_TH'] ?? '';
    final mapEntry = <String, String>{key: value};
    map.addEntries(mapEntry.entries);
  }
  return map;
}

/// 将excel表数据转换成json数组
Future<List<List<Map<String, String>>>> excelToJson() async {
  final file = './example/excel/tha_adm_feature_areas_20191106.xlsx';
  final bytes = await File(file).readAsBytes();
  final excel = Excel.decodeBytes(bytes);

  final list = <List<Map<String, String>>>[];

  for (final key in excel.tables.keys) {
    final table = excel.tables[key]!;

    // 有多少竖列的数据(keys)
    final column = table.maxCols;

    // 有多少横行的数据(包含了第一行的keys)
    final row = table.maxRows;

    // 2-D dynamic List
    final rows = table.rows;

    // list
    final maps = <Map<String, String>>[];

    // for
    for (var i = 1; i < row; i++) {
      final map = <String, String>{};

      for (var j = 0; j < column; j++) {
        final data0 = rows[0][j];
        final data0Value = data0?.value;
        final key = data0Value.toString();

        final data = rows[i][j];
        final dataValue = data?.value;
        final value = dataValue.toString();

        final mapEntry = <String, String>{
          key: value,
        };
        map.addEntries(mapEntry.entries);
      }

      maps.add(map);
    }

    list.add(maps);
  }

  return list;
}
