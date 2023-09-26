import 'dart:convert';
import 'package:dictarchive/screens/download_prompt.dart';
import 'package:dictarchive/screens/info_prompt.dart';
import 'package:dictarchive/utils/package_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

final dio = Dio();

class DictsManager extends ChangeNotifier {
  Map<String, dynamic> downloadableDictsList = {},
      installedDictsList = {},
      searchOnDict = {};
  Database? selectedDictDatabase;
  Map<String, Object?> selectedWord = {};

  DictsManager() {
    getSearchOnDict().then((_) => intializeDictPack(searchOnDict["code_name"])
        .then((_) => getInstalledDictsList()));
  }

  Future getInstalledDictsList() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      installedDictsList = jsonDecode(prefs.getString("installed_dicts")!);
      notifyListeners();
    } catch (_) {}
  }

  Future getDownloadableDictsList({bool? refresh}) async {
    refresh = refresh ?? false;
    if (downloadableDictsList.isEmpty || refresh) {
      try {
        final request = await dio.get(
            "https://raw.githubusercontent.com/Neurs12/dictarchive/main/dicts.json");
        if (request.statusCode == 200) {
          downloadableDictsList = {
            "result": true,
            "data": jsonDecode(request.data)
          };
          notifyListeners();
        } else {
          downloadableDictsList = {"result": false};
          notifyListeners();
        }
      } catch (_) {
        downloadableDictsList = {"result": false};
        notifyListeners();
      }
    }
  }

  showDownloadDialog(Map obj, BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadPrompt(
            packName: obj["pack_name"],
            licenseUrl: obj["license"],
            packUrl: obj["dict_pack"],
            codeName: obj["code_name"]));
  }

  showInfoDialog(Map obj, BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => InfoPrompt(
            packName: obj["pack_name"],
            licenseUrl: obj["license"],
            codeName: obj["code_name"]));
  }

  Future setSearchOnDict(
      String codeName, String fileName, String packName) async {
    final prefs = await SharedPreferences.getInstance();

    searchOnDict = {
      "code_name": codeName,
      "filename": fileName,
      "pack_name": packName
    };
    await prefs.setString("searchOnDict", jsonEncode(searchOnDict));

    await intializeDictPack(codeName);
  }

  Future getSearchOnDict() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      searchOnDict = jsonDecode(prefs.getString("searchOnDict")!);
    } catch (_) {}
    notifyListeners();
  }

  Future intializeDictPack(String? codeName) async {
    if (codeName != null) {
      selectedDictDatabase =
          await openReadOnlyDatabase(await getSavePath("$codeName.sqlite"));
    }
    notifyListeners();
  }

  Future<List<Map<String, Object?>>> searchQuery(String query) async {
    return query != ""
        ? await selectedDictDatabase!.rawQuery(
            "SELECT * FROM lang WHERE word like ? LIMIT 0,100", ["$query%"])
        : [];
  }

  requestNotify() {
    notifyListeners();
  }

  selectWord(Map<String, Object?> selected) {
    selectedWord = selected;
    notifyListeners();
  }

  Future getDefinitionFromWord(String word) async {
    for (int tries = word.length; tries >= 0; tries--) {
      try {
        selectedWord = (await selectedDictDatabase!.rawQuery(
            "SELECT * FROM lang WHERE word = ?",
            [word.toLowerCase().substring(0, tries)]))[0];
        break;
      } catch (_) {}
    }
    notifyListeners();
  }
}
