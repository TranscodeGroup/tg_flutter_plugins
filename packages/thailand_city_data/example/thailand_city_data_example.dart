import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:characters/characters.dart';
import 'package:excel/excel.dart';

void main(List<String> args) async {
  final list = excelToJson();

  final provinceMap = getProvince(list[1]);
  saveToFile(
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
    File jsonFile = File('lib/src/$fileName.dart');

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
  var map =
      SplayTreeMap<String, Map<String, Map<String, String>>>((key1, key2) {
    return key1.compareTo(key2);
  });

  for (var province in provinceList) {
    final provinceCode = province['ADM1_PCODE'] ?? '';

    var kMap = SplayTreeMap<String, Map<String, String>>((key1, key2) {
      return key1.compareTo(key2);
    });

    for (var district in districtList) {
      final name = district['ADM2_TH'] ?? '';
      final code = district['ADM2_PCODE'] ?? '';

      if (provinceCode == district['ADM1_PCODE']) {
        var mMap = <String, String>{};
        var mMapEntry = <String, String>{
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
  var map = SplayTreeMap<String, String>((key1, key2) {
    return key1.compareTo(key2);
  });

  for (var province in provinceList) {
    final key = province['ADM1_PCODE'] ?? '';
    final value = province['ADM1_TH'] ?? '';
    final mapEntry = <String, String>{key: value};
    map.addEntries(mapEntry.entries);
  }
  return map;
}

/// 将excel表数据转换成json数组
List<List<Map<String, String>>> excelToJson() {
  var file = './example/excel/tha_adm_feature_areas_20191106.xlsx';
  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  var list = <List<Map<String, String>>>[];

  for (var key in excel.tables.keys) {
    final table = excel.tables[key]!;

    // 有多少竖列的数据(keys)
    final column = table.maxCols;

    // 有多少横行的数据(包含了第一行的keys)
    final row = table.maxRows;

    // 2-D dynamic List
    final rows = table.rows;

    // list
    var maps = <Map<String, String>>[];

    // for
    for (var i = 1; i < row; i++) {
      var map = <String, String>{};

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
