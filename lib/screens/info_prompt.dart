import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:dictarchive/utils/package_manager.dart';
import 'package:dio/dio.dart';

class InfoPrompt extends StatelessWidget {
  final String packName, licenseUrl, codeName;
  const InfoPrompt(
      {super.key,
      required this.packName,
      required this.licenseUrl,
      required this.codeName});

  @override
  Widget build(BuildContext context) {
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
              child: const Text("Delete"),
              onPressed: () => deleteQueue(codeName, context)
                  .then((_) => Navigator.of(context).pop())),
          TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop())
        ]);
  }
}
