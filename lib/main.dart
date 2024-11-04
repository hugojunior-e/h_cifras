import 'dart:io';

import 'package:flutter/material.dart';
import 'constantes.dart';
import 'cifra.dart';
import 'package:dio/dio.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Tema escuro
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
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
  String s_download = "";

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
    final file = File('$constDownloadDir/hcifras.db');
    if (await file.exists()) {
      await file.delete();
    }

    isFiltered = false;
    await ddb.doFilter("");

    Dio dio = Dio();

    await dio.download(
      'http://200.98.168.231:8585/hcifras/hcifras.db',
      '$constDownloadDir/hcifras.db',
      onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            s_download = "${(received / total * 100).toStringAsFixed(0)}%";
          });
        }
      },
    );
    setState(() {
      s_download = 'Download completed... Restart APP to apply.';
    });
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
      MaterialPageRoute(builder: (context) => CifraStateModel(index)),
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
        //-----------------------------------------------------
        //---
        floatingActionButton: SpeedDial(
          //closeManually: true,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(size: 22.0),
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8.0,
          shape: const CircleBorder(),
          children: [
            SpeedDialChild(
                child: const Icon(Icons.playlist_play_sharp),
                backgroundColor: Colors.red,
                onTap: () {
                  download();
                }),
            SpeedDialChild(
                child: const Icon(Icons.download),
                backgroundColor: Colors.red,
                onTap: () {
                  download();
                }),
            SpeedDialChild(
                child: Icon(isFiltered ? Icons.favorite : Icons.list),
                backgroundColor: Colors.blue,
                onTap: () {
                  search("...");
                }),
          ],
        ),

        //---
        //-----------------------------------------------------

        body: ddb.listaFiltrada.isEmpty
            ? Center(
                child: Text(
                  s_download,
                  style: const TextStyle(fontSize: 18),
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

