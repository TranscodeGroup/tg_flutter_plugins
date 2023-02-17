import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:characters/characters.dart';
import 'package:excel/excel.dart';

void main(List<String> args) async {
  final list = await excelToJson();

  // 保存到excel
  final newTownList = getTownList(list[1], list[2], list[3]);
  saveToExcel(
    newTownList,
    path: './example/excel/tha_adm_feature_areas_output.xlsx',
  );

  // 保存到dart文件
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

/// 保存到excel文件
void saveToExcel(
  List<Map<String, String>> list, {
  required String path,
}) {
  // list数组最前面插入1个数据(key)
  final firstObject = list.first;
  list.insert(0, firstObject);

  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Th'];

  for (var i = 0; i < list.length; i++) {
    final item = list[i];
    final keys = item.keys.toList();
    for (var j = 0; j < keys.length; j++) {
      final key = keys[j];
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(
          columnIndex: j,
          rowIndex: i,
        ),
      );
      cell.value = (i == 0) ? key : item[key];
    }
  }

  var fileBytes = excel.save();
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);
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

/// 生成行政区划之镇的json数组
List<Map<String, String>> getTownList(
  List<Map<String, String>> provinceList,
  List<Map<String, String>> districtList,
  List<Map<String, String>> townList,
) {
  // 1.
  final newProvinceList = provinceList.map((province) {
    final mapEntry = <String, String>{
      'code_country': 'Thailand',
      'code_prov': province['ADM1_PCODE'] ?? '',
      'name_prov': province['ADM1_TH'] ?? '',
    };
    return Map.fromEntries(mapEntry.entries);
  }).toList();

  // 2.
  var newDistrictList = <Map<String, String>>[];

  for (var newProvince in newProvinceList) {
    final codeProv = newProvince['code_prov'];

    for (var district in districtList) {
      if (codeProv == district['ADM1_PCODE']) {
        final mapEntry = <String, String>{
          'code_country': 'Thailand',
          'code_prov': district['ADM1_PCODE'] ?? '',
          'name_prov': district['ADM1_TH'] ?? '',
          'code_city': district['ADM2_PCODE'] ?? '',
          'name_city': district['ADM2_TH'] ?? '',
        };
        final map = Map.fromEntries(mapEntry.entries);
        newDistrictList.add(map);
      }
    }
  }

  // 3.
  var newTownList = <Map<String, String>>[];

  for (var newDistrict in newDistrictList) {
    final codeCity = newDistrict['code_city'];
    for (var town in townList) {
      if (codeCity == town['ADM2_PCODE']) {
        final mapEntry = <String, String>{
          'code_country': 'Thailand',
          'code_prov': town['ADM1_PCODE'] ?? '',
          'name_prov': town['ADM1_TH'] ?? '',
          'code_city': town['ADM2_PCODE'] ?? '',
          'name_city': town['ADM2_TH'] ?? '',
          'code_coun': town['ADM3_PCODE'] ?? '',
          'name_coun': town['ADM3_TH'] ?? '',
        };
        final map = Map.fromEntries(mapEntry.entries);
        newTownList.add(map);
      }
    }
  }

  newTownList.sort((a, b) {
    final key1 = a['code_coun'] ?? '';
    final key2 = b['code_coun'] ?? '';
    return key1.compareTo(key2);
  });

  return newTownList;
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
