import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constantes.dart';
import 'Navegador.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: constTitulo,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SearchScreenStateModel(),
    );
  }
}

//-----------------------------------------------------------------------------------------------------

class SearchScreenStateModel extends StatefulWidget {
  const SearchScreenStateModel({super.key});

  @override
  State<SearchScreenStateModel> createState() => SearchScreen();
}

//-----------------------------------------------------------------------------------------------------

class SearchScreen extends State<SearchScreenStateModel> {
  bool isFiltered = false;
  bool hasInitialized = false;

  late TextEditingController myController = TextEditingController();

  String removeDiacritics(String str) {
    const withDiacritics =
        'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÑñÇç';
    const withoutDiacritics =
        'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuNnCc';

    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }

    str = str.replaceAll(RegExp(r'[^\w\s]+'),
        ''); // Remove caracteres especiais, exceto espaços e letras

    return str;
  }

  void download() async {
    final file = File('/storage/emulated/0/Download/hcifras.db');

    if (await file.exists()) {
      await file.delete();
    }
    
    if (!hasInitialized) {
      await FlutterDownloader.initialize(
        debug: true, // Coloque como 'false' para remover logs em produção
        ignoreSsl:
            true, // Use true se estiver lidando com URLs sem SSL adequados
      );
      hasInitialized = true;
    }

    await FlutterDownloader.enqueue(
      url: 'http://200.98.168.231:8585/hcifras/hcifras.db',
      savedDir: '/storage/emulated/0/Download/',
      showNotification: true,
      openFileFromNotification: false,
    );
    
  }

  void search(String query) async {
    if (query.contains("...")) {
      myController.text = '';
      if (isFiltered) {
        isFiltered = false;
        await ddb.doFilter("");
      } else {
        isFiltered = true;
        await ddb.doFilter("...");
      }
    } else {
      isFiltered = false;
      await ddb.doFilter(removeDiacritics(query));
    }

    setState(() {});
  }

  void itemBuilderOnTap(index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NavegadorStateModel(index)),
    );
  }
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) {
              search(value);
            },
            controller: myController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(
                Icons.search,
              ),
            ),
          ),
        ),
        //------------
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  download();

                  showAlertDialog(context, "Mensagem",
                      "O Aplicativo sera finalizado para ser atualizado...");

                  Future.delayed(const Duration(seconds: 3), () {
                    SystemNavigator.pop();
                  });
                },
                child: const Icon(Icons.download),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: () {
                  search("...");
                },
                child: Icon(isFiltered ? Icons.favorite : Icons.list),
              ),
            ]),
        //-----------
        body: ddb.listaFiltrada.isEmpty
            ? const Center(
                child: Text(
                  'No Results Found',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.separated(
                itemCount: ddb.listaFiltrada.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: const Icon(Icons.music_note,
                          color: Color.fromARGB(255, 199, 39, 39), size: 30.0),
                      title: Text(
                        ddb.getTitulo(index).split('/')[2].replaceAll("-", " "),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: <Widget>[
                          Text(ddb.getTitulo(index).split('/')[1])
                        ],
                      ),
                      onTap: () => itemBuilderOnTap(index),
                      trailing: const Icon(Icons.keyboard_arrow_right,
                          color: Color.fromARGB(255, 199, 39, 39), size: 30.0));
                },
              ));
  }
}

//-----------------------------------------------------------------------------------------------------

