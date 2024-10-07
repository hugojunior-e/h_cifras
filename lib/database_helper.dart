import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class Musica {
  late int id;
  late String titulo;
  late String tom;
  late String cifra;
  late String fav_tom;
  late String yt;
}

class DatabaseHelper {
  late sql.Database db;
  late bool oppened = false;

  List<Musica> listaFiltrada = [];

  DatabaseHelper() {
    sqfliteFfiInit();
    try {
      sql.openDatabase('/storage/emulated/0/Download/hcifras.db',
          version: 1, onCreate: dbOnCreate, onOpen: dbOnOpen);
      oppened = true;
    } catch (e) {
    }
  }

  void dbOnCreate(sql.Database database, int version) {
    database.execute("""
      CREATE TABLE items(
        id          INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
        titulo      varchar(100),
        tom         varchar(10),
        cifra       TEXT,
        fav_tom     varchar(10),
        yt          varchar(30)
      )
      """);

    if (kDebugMode) {
      print("Database Criado");
    }
  }

  void dbOnOpen(sql.Database database) {
    db = database;
  }

  Future<bool> doFilter(String query) async {
    var q = "";

    if (!oppened) {
      return true;
    }

    listaFiltrada.clear();

    if (query.contains("...")) {
      q = "select * from items where fav_tom is not null";
    } else {
      if ( query.length < 3 ) {
        return true;
      }
      q = "select * from items where 1=1";
      for (String s in query.toLowerCase().split(" ")) {
        q = "$q and titulo like '%$s%'";
      }
    } //youtubeId: 'ePdRgBWhvog',
    
    await db.rawQuery(q).then( (onValue) {
      for (int i=0; i < onValue.length; i++) {
        Musica m = Musica();
        m.id = onValue[i]['id'] as int;
        m.titulo = onValue[i]['titulo'] as String;
        m.tom = onValue[i]['tom'] as String;
        m.cifra = onValue[i]['cifra'] as String;
        m.fav_tom = onValue[i]['fav_tom'] == null ? "" : (onValue[i]['fav_tom'] as String);
        m.yt = onValue[i]['yt'] == null ? "" : (onValue[i]['yt'] as String);

        listaFiltrada.add( m );
      }
        print(listaFiltrada.length);
    });
    return true;
  }

  int getId(index) {
    return listaFiltrada[index].id;
  }

  String getTitulo(index) {
    return listaFiltrada[index].titulo;
  }

  String getTom(index) {
    return listaFiltrada[index].tom;
  }
  String getCifra(index) {
    return listaFiltrada[index].cifra;
  }
  String getFavTom(index) {
    return listaFiltrada[index].fav_tom;
  }

  String getYt(index) {
    return listaFiltrada[index].yt;
  }  

  void addToFavorite(int index, String newFavTom) {
    final int id = getId(index);
    if (newFavTom.isEmpty) {
      db.rawUpdate("update items set fav_tom=null where id=?", [id]);
    } else {
      db.rawUpdate("update items set fav_tom=? where id=?", [newFavTom, id]);
    }
    listaFiltrada[index].fav_tom = newFavTom;
  }
}
