import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:dictarchive/utils/package_manager.dart';
import 'package:dio/dio.dart';

class DownloadPrompt extends StatelessWidget {
  final String packName, licenseUrl, packUrl, codeName;
  const DownloadPrompt(
      {super.key,
      required this.packName,
      required this.licenseUrl,
      required this.packUrl,
      required this.codeName});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Map<String, int>> progress =
        ValueNotifier<Map<String, int>>({"count": 0, "total": 0});
    Dio dio = Dio();
    return AlertDialog(
        title: const Text("Dictionary", textAlign: TextAlign.center),
        content: SingleChildScrollView(
            child: Column(children: [
          Text(packName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color:
                      Theme.of(context).colorScheme.background.withOpacity(.5)),
              child: FutureBuilder(
                  future: dio.get(licenseUrl),
                  builder: (context, snapshot) => snapshot.connectionState ==
                          ConnectionState.done
                      ? Markdown(selectable: true, data: snapshot.data!.data)
                      : Container()))
        ])),
        actions: <Widget>[
          TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
              child: ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (context, _, __) => Text(progress.value["count"] ==
                              0 &&
                          progress.value["total"] == 0
                      ? "Download"
                      : "${(progress.value["count"]! / progress.value["total"]! * 100).toInt()}%")),
              onPressed: () => downloadQueue(packUrl, "$codeName.sqlite",
                      packName, codeName, progress, context)
                  .then((_) => Navigator.of(context).pop()))
        ]);
  }
}
