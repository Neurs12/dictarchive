import 'dart:convert';
import 'dart:io';
import 'package:dictarchive/providers/dicts_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> getSavePath(String filename) async {
  return "${(await getApplicationDocumentsDirectory()).path}/$filename";
}

Future<bool> addToLib(String filename, String packName, String codeName) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    Map<String, dynamic> update =
        jsonDecode(prefs.getString("installed_dicts")!);
    update.addAll({
      codeName: {"filename": filename, "pack_name": packName}
    });
    await prefs.setString("installed_dicts", jsonEncode(update));
  } catch (_) {
    await prefs.setString(
        "installed_dicts",
        jsonEncode({
          codeName: {"filename": filename, "pack_name": packName}
        }));
  }

  return true;
}

Future<bool> downloadQueue(
    String url,
    String filename,
    String packName,
    String codeName,
    ValueNotifier<Map<String, int>> progress,
    BuildContext context) async {
  Dio dio = Dio();

  await dio.download(url, await getSavePath(filename),
      onReceiveProgress: (count, total) => {
            progress.value = {"count": count, "total": total}
          });

  await addToLib(filename, packName, codeName);
  if (!context.mounted) return false;
  await Provider.of<DictsManager>(context, listen: false)
      .getInstalledDictsList();

  return true;
}

Future<bool> deleteQueue(String codeName, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  if (!context.mounted) return false;
  if (Provider.of<DictsManager>(context, listen: false)
          .searchOnDict["code_name"] ==
      codeName) {
    await Provider.of<DictsManager>(context, listen: false)
        .selectedDictDatabase!
        .close();
    await prefs.remove("searchOnDict");
    if (!context.mounted) return false;
    Provider.of<DictsManager>(context, listen: false).searchOnDict = {};
  }

  await File(await getSavePath("$codeName.sqlite")).delete();

  Map<String, dynamic> update = jsonDecode(prefs.getString("installed_dicts")!);
  update.remove(codeName);
  await prefs.setString("installed_dicts", jsonEncode(update));

  if (!context.mounted) return false;
  Provider.of<DictsManager>(context, listen: false).installedDictsList = update;
  Provider.of<DictsManager>(context, listen: false).requestNotify();

  return true;
}
