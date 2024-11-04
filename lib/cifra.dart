import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'constantes.dart';
import 'package:web_browser/web_browser.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CifraStateModel extends StatefulWidget {
  final int index;

  const CifraStateModel(this.index, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<CifraStateModel> createState() => Cifra(index);
}

// ignore: must_be_immutable
class Cifra extends State<CifraStateModel> {
  var html = "";
  var linkTag = "";
  var linkYouTube = "";
  var ctrl = WebViewController();
  final int index;

  Cifra(this.index) {
    linkTag = ddb.getYt(index);
    linkYouTube = "https://www.youtube.com/watch?v=$linkTag";

    html = constHTML
        .replaceAll("#TOM#", ddb.getTom(index))
        .replaceAll("#CIFRA#", ddb.getCifra(index));

    String novoTom = ddb.getFavTom(index).isEmpty
        ? ""
        : "<script> go_to_tom('${ddb.getFavTom(index)}'); </script>";
    html = Uri.dataFromString("$html} $novoTom",
            mimeType: 'text/html', encoding: utf8)
        .toString();
  }

  void onClickButtonAddFavorite() {
    ctrl.runJavaScriptReturningResult("fta()").then((onValue) {
      setState(() {
        String textAviso = "";
        String newFavTom = "";
        if (ddb.getFavTom(index).isEmpty) {
          newFavTom = onValue.toString().replaceAll("\"", "");
          textAviso = "Adicionado aos Favoritos...";
        } else {
          textAviso = "Removido dos Favoritos...";
        }
        ddb.addToFavorite(index, newFavTom);
        showAlertDialog(context, "Mensagem", textAviso);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: const Icon(Icons.add),
              backgroundColor: Colors.red,
              onTap: () {
                ctrl.runJavaScript("rep('+')");
              }),
          SpeedDialChild(
              child: const Icon(Icons.remove),
              backgroundColor: Colors.blue,
              onTap: () {
                ctrl.runJavaScript("rep('-')");
              }),
          SpeedDialChild(
            child: Icon(ddb.getFavTom(index).isNotEmpty
                ? Icons.favorite
                : Icons.bookmark_border),
            backgroundColor: Colors.green,
            onTap: onClickButtonAddFavorite,
          ),
          SpeedDialChild(
              child: const Icon(Icons.abc),
              backgroundColor: Colors.yellow,
              onTap: () {
                ctrl.runJavaScript("letra()");
              }),
          SpeedDialChild(
              child: const Icon(Icons.youtube_searched_for),
              backgroundColor: Colors.red,
              onTap: () {
                if (linkTag.length < 4) {
                  showAlertDialog(context, "Mensagem", "Video nao disponivel");
                } else {
                  launchURL(linkYouTube);
                }
              }),
        ],
      ),

      //-----------------------------------------
      //
      //-----------------------------------------
      body: SafeArea(
        child: Browser(
            topBar: null,
            bottomBar: null,
            initialUriString: html,
            controller: BrowserController(
              webViewController: ctrl,
            )),
      ),
    );
  }
}
