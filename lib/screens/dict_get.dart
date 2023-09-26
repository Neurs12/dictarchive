import 'package:dictarchive/providers/dicts_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DictGet extends StatefulWidget {
  const DictGet({super.key});

  @override
  State<StatefulWidget> createState() => _DictGetState();
}

class _DictGetState extends State<DictGet> {
  @override
  void initState() {
    super.initState();

    Provider.of<DictsManager>(context, listen: false)
        .getInstalledDictsList()
        .then((_) => Provider.of<DictsManager>(context, listen: false)
            .getDownloadableDictsList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Download dictionary")),
        body: Consumer<DictsManager>(builder: (context, dictsManager, child) {
          if (dictsManager.downloadableDictsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          var shorterName = dictsManager.downloadableDictsList["data"];
          return RefreshIndicator(
              onRefresh: () =>
                  dictsManager.getDownloadableDictsList(refresh: true),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                      itemBuilder: (context, index) => DictDisplay(
                          codeName: shorterName[index]["code_name"],
                          packName: shorterName[index]["pack_name"],
                          contributor: shorterName[index]["contributor"],
                          dictPack: shorterName[index]["dict_pack"],
                          license: shorterName[index]["license"],
                          packSize: shorterName[index]["pack_size"],
                          installedDictsList: dictsManager.installedDictsList,
                          searchOnDict: dictsManager.searchOnDict,
                          starPressed: () => dictsManager.setSearchOnDict(
                              shorterName[index]["code_name"],
                              "${shorterName[index]["code_name"]}.sqlite",
                              shorterName[index]["pack_name"]),
                          downloadPressed: () => dictsManager
                              .showDownloadDialog(shorterName[index], context),
                          infoPressed: () => dictsManager.showInfoDialog(
                              shorterName[index], context)),
                      itemCount: shorterName.length)));
        }));
  }
}

class DictDisplay extends StatelessWidget {
  final String codeName, packName, contributor, packSize, dictPack, license;
  final Map<String, dynamic> installedDictsList, searchOnDict;
  final Function() starPressed, downloadPressed, infoPressed;
  const DictDisplay(
      {super.key,
      required this.packName,
      required this.contributor,
      required this.packSize,
      required this.installedDictsList,
      required this.codeName,
      required this.searchOnDict,
      required this.dictPack,
      required this.license,
      required this.starPressed,
      required this.downloadPressed,
      required this.infoPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 3),
            child: ListTile(
                leading: const Icon(Icons.translate),
                title: Text(packName),
                subtitle: Text("Uploader: $contributor"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  installedDictsList.containsKey(codeName)
                      ? IconButton(
                          onPressed: infoPressed,
                          icon: const Icon(Icons.info_outline))
                      : Text(packSize),
                  const SizedBox(width: 5),
                  installedDictsList.containsKey(codeName)
                      ? searchOnDict["code_name"] == codeName
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.star))
                          : IconButton(
                              onPressed: starPressed,
                              icon: const Icon(Icons.star_outline))
                      : IconButton(
                          onPressed: downloadPressed,
                          icon: const Icon(Icons.downloading))
                ]))));
  }
}
