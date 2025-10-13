import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';

void main(List<String> args) async {
  final list = await excelToJson();

  // 保存到excel
  final newTownList = getTownList(list[1], list[2], list[3]);
  await saveToExcel(
    newTownList,
    path: 'generator/excel/tha_adm_feature_areas_output.xlsx',
  );

  // 保存到dart文件
  final provinceMap = getProvince(list[1]);
  await saveToFile(
    provinceMap,
    field: 'Map<String, String> thProvincesData',
    fileName: 'province',
  );

  final districtMap = getDistrict(list[1], list[2], list[3]);
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
Future<void> saveToExcel(
  List<Map<String, String>> list, {
  required String path,
}) async {
  // list数组最前面插入1个数据(key)
  final firstObject = list.first;
  list.insert(0, firstObject);

  final excel = Excel.createExcel();
  final Sheet sheetObject = excel['Th'];

  for (var i = 0; i < list.length; i++) {
    final item = list[i];
    final keys = item.keys.toList();
    for (var j = 0; j < keys.length; j++) {
      final key = keys[j];
      final cell = sheetObject.cell(
        CellIndex.indexByColumnRow(
          columnIndex: j,
          rowIndex: i,
        ),
      );
      cell.value = (i == 0) ? key : item[key];
    }
  }

  final fileBytes = excel.save();

  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsBytes(fileBytes!);
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
      '''/// Generated file. Do not edit.
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
  final newProvinceList = provinceList
      .map((province) => {
            'code_country': 'Thailand',
            'code_prov': province['ADM1_PCODE'] ?? '',
            'name_prov': province['ADM1_TH'] ?? '',
          })
      .toList();

  final newDistrictList = <Map<String, String>>[];

  for (final newProvince in newProvinceList) {
    final codeProv = newProvince['code_prov'];

    for (final district in districtList) {
      if (codeProv == district['ADM1_PCODE']) {
        newDistrictList.add(
          {
            'code_country': 'Thailand',
            'code_prov': district['ADM1_PCODE'] ?? '',
            'name_prov': district['ADM1_TH'] ?? '',
            'code_city': district['ADM2_PCODE'] ?? '',
            'name_city': district['ADM2_TH'] ?? '',
          },
        );
      }
    }
  }

  final newTownList = <Map<String, String>>[];

  for (final newDistrict in newDistrictList) {
    final codeCity = newDistrict['code_city'];
    for (final town in townList) {
      if (codeCity == town['ADM2_PCODE']) {
        newTownList.add(
          {
            'code_country': 'Thailand',
            'code_prov': town['ADM1_PCODE'] ?? '',
            'name_prov': town['ADM1_TH'] ?? '',
            'code_city': town['ADM2_PCODE'] ?? '',
            'name_city': town['ADM2_TH'] ?? '',
            'code_coun': town['ADM3_PCODE'] ?? '',
            'name_coun': town['ADM3_TH'] ?? '',
          },
        );
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
  List<Map<String, String>> townList,
) {
  final map = SplayTreeMap<String, Map<String, Map<String, String>>>();

  for (final town in townList) {
    final districtCode = town['ADM2_PCODE'] ?? '';

    final townMap = SplayTreeMap<String, Map<String, String>>();

    for (final town in townList) {
      if (districtCode == town['ADM2_PCODE']) {
        final name = town['ADM3_TH'] ?? '';
        final code = town['ADM3_PCODE'] ?? '';
        townMap[code] = <String, String>{
          'name': name,
          'alpha': name[0],
        };
      }
    }

    map[districtCode] = townMap;
  }

  for (final province in provinceList) {
    final provinceCode = province['ADM1_PCODE'] ?? '';

    final districtMap = SplayTreeMap<String, Map<String, String>>();

    for (final district in districtList) {
      if (provinceCode == district['ADM1_PCODE']) {
        final name = district['ADM2_TH'] ?? '';
        final code = district['ADM2_PCODE'] ?? '';
        districtMap[code] = <String, String>{
          'name': name,
          'alpha': name[0],
        };
      }
    }

    map[provinceCode] = districtMap;
  }

  return map;
}

/// 生成行政区划之府的json
Map<String, String> getProvince(List<Map<String, String>> provinceList) {
  final map = SplayTreeMap<String, String>();

  for (final province in provinceList) {
    final key = province['ADM1_PCODE'] ?? '';
    final value = province['ADM1_TH'] ?? '';

    map[key] = value;
  }
  return map;
}

/// 将excel表数据转换成json数组
Future<List<List<Map<String, String>>>> excelToJson() async {
  final file = 'generator/excel/tha_adm_feature_areas_20191106.xlsx';
  final bytes = await File(file).readAsBytes();
  final excel = Excel.decodeBytes(bytes);

  final sheets = <List<Map<String, String>>>[];

  for (final table in excel.tables.values) {
    // 2-D dynamic List
    final rows = table.rows;
    final sheet = <Map<String, String>>[];

    final keyRow = rows[0];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final item = <String, String>{};

      for (var j = 0; j < row.length; j++) {
        final key = (keyRow[j]?.value).toString();
        final value = (row[j]?.value).toString();

        item[key] = value;
      }

      sheet.add(item);
    }

    sheets.add(sheet);
  }

  return sheets;
}
