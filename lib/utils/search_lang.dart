import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> loadDictAssetDb() async {
  String dbPath =
      "${(await getApplicationDocumentsDirectory()).path}/anhviet109K.sqlite";
  if (!(await File(dbPath).exists())) {
    ByteData data = await rootBundle.load("assets/anhviet109K.sqlite");
    await File(dbPath).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true);
  }
  var db = await openDatabase(dbPath);
  print(await db.rawQuery("SELECT * FROM 'data' LIMIT 0,30"));
}