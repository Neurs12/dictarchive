import 'package:dictarchive/providers/dicts_manager.dart';
import 'package:dictarchive/screens/dict_get.dart';
import 'package:dictarchive/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Dict Archive"), actions: [
          IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const DictGet())),
              icon: const Icon(Icons.translate))
        ]),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Consumer<DictsManager>(
                builder: (context, dictsManager, _) => Column(children: [
                      GestureDetector(
                          onTap: () => dictsManager.searchOnDict
                                  .containsKey("code_name")
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SearchWord()))
                              : showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                      title: Text("No dictionary selected"),
                                      content: Text(
                                          "You haven't selected any dictionary to search. Try download and select one!"))),
                          child: Search(
                              title:
                                  "Lookup dictionary (${dictsManager.searchOnDict["pack_name"] ?? "Unselected"})")),
                      const SizedBox(height: 20),
                      dictsManager.selectedWord.isNotEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height - 150,
                              width: MediaQuery.of(context).size.width,
                              child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: DefinitionDisplayer(
                                      source: dictsManager
                                          .selectedWord["definition"]
                                          .toString()
                                          .split("<br>"))))
                          : Container()
                    ]))));
  }
}

class Search extends StatelessWidget {
  final String title;
  const Search({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(69),
            border: Border.all(
                color: Theme.of(context).colorScheme.outline, width: .5)),
        height: 50,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search),
          const SizedBox(width: 10),
          Text(title)
        ]));
  }
}

class DefinitionDisplayer extends StatefulWidget {
  final List<String> source;
  const DefinitionDisplayer({super.key, required this.source});

  @override
  State<StatefulWidget> createState() => _DefinitionDisplayerState();
}

class _DefinitionDisplayerState extends State<DefinitionDisplayer> {
  FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    tts.setLanguage("en-us");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formattedText = [];
    int definitionCount = 1;
    bool previousIsQuote = false;
    for (String line in widget.source) {
      if (line.isNotEmpty) {
        if (line.startsWith("@")) {
          formattedText.add(Row(children: [
            Text(capitalize(line.substring(1)),
                style: Theme.of(context).textTheme.headlineSmall),
            IconButton(
                onPressed: () => tts.speak(line.substring(1).split(" ")[0]),
                icon: const Icon(Icons.volume_up_rounded))
          ]));
        }

        if (line[0] == "*") {
          if (line[2] != " ") {
            formattedText.add(Text(capitalize(line.substring(2)),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)));
          } else {
            formattedText.add(const SizedBox(height: 10));
            formattedText.add(Text(capitalize(line.substring(3)),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)));
            definitionCount = 1;
          }
        }

        if (line.startsWith("- ")) {
          if (!previousIsQuote) {
            if (definitionCount > 1) {
              formattedText.add(const SizedBox(height: 10));
            }
            formattedText.add(Text(
                "Nghĩa $definitionCount: ${capitalize(line.substring(2))}",
                style: const TextStyle(fontWeight: FontWeight.bold)));
            definitionCount++;
          } else {
            formattedText.add(Text("> ${capitalize(line.substring(2))}"));
            previousIsQuote = false;
          }
        }

        if (line.startsWith("=")) {
          List<String> sub = line.split("+");
          previousIsQuote = true;

          formattedText
              .add(Wrap(children: generateIndex(sub[0].substring(1), context)));
          try {
            formattedText.add(Text("> ${capitalize(sub[1])}"));
          } catch (_) {}
        }

        if (line.startsWith("!")) {
          previousIsQuote = true;
          formattedText
              .add(Wrap(children: generateIndex(line.substring(1), context)));
        }
      }
    }

    formattedText.add(const SizedBox(height: 20));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: formattedText);
  }
}

String capitalize(String s) {
  while (s[0] == " ") {
    s = s.substring(1);
  }
  return s[0].toUpperCase() + s.substring(1);
}

List<Widget> generateIndex(String source, BuildContext context) {
  RegExp exp = RegExp(r"[A-Za-z']+");
  List<Widget> pushOver = [
    const Text("“", style: TextStyle(fontWeight: FontWeight.w500))
  ];
  List<String> specialChars = source.split(exp);
  List<String> words = [for (RegExpMatch di in exp.allMatches(source)) di[0]!];
  int specialCharsIndex = 0, wordsIndex = 0;

  for (int i = 0; i < specialChars.length + words.length; i++) {
    if (i % 2 == 0) {
      pushOver.add(Text(specialChars[specialCharsIndex],
          style: const TextStyle(fontWeight: FontWeight.w500)));
      specialCharsIndex++;
    } else {
      String setWord = words[wordsIndex];
      pushOver.add(GestureDetector(
          onTap: () => Provider.of<DictsManager>(context, listen: false)
              .getDefinitionFromWord(setWord),
          child: Text(wordsIndex == 0 ? capitalize(setWord) : setWord,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline))));
      wordsIndex++;
    }
  }

  pushOver.add(const Text("‟", style: TextStyle(fontWeight: FontWeight.w500)));

  return pushOver;
}
