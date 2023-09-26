import 'package:dictarchive/providers/dicts_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchWord extends StatefulWidget {
  const SearchWord({super.key});

  @override
  State<StatefulWidget> createState() => _SearchWordState();
}

class _SearchWordState extends State<SearchWord> {
  ValueNotifier<List<Map<String, Object?>>> searchResult =
      ValueNotifier<List<Map<String, Object?>>>([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      Row(children: [
        Padding(
            padding: const EdgeInsets.only(top: 4),
            child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 20))),
        const SizedBox(width: 5),
        Expanded(
            child: Consumer<DictsManager>(
                builder: (context, dictsManager, _) => TextField(
                    autofocus: true,
                    onChanged: (v) async =>
                        searchResult.value = await dictsManager.searchQuery(v),
                    decoration: InputDecoration(
                        hintText:
                            "Lookup dictionary (${dictsManager.searchOnDict["pack_name"]})",
                        border: InputBorder.none))))
      ]),
      const Divider(),
      Expanded(
          child: ValueListenableBuilder(
              valueListenable: searchResult,
              builder: (context, _, __) => ListView.builder(
                  itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Provider.of<DictsManager>(context, listen: false)
                            .selectWord(searchResult.value[index]);
                      },
                      child: ListTile(
                          leading: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(69),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(.5)),
                              width: 32,
                              height: 32,
                              child: const Icon(Icons.search)),
                          title: Text(
                              searchResult.value[index]["word"].toString()))),
                  itemCount: searchResult.value.length)))
    ])));
  }
}
