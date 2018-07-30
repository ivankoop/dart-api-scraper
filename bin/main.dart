import 'package:dart_set_scraper/dart_set_scraper.dart' as dart_set_scraper;
import 'dart:async';
import 'dart:convert';
import 'package:sqljocky/sqljocky.dart';
import 'package:http/http.dart' as http;

String set_url = "https://servicios.set.gov.py/eset-publico/ciudadano/recuperar?cedula=";
int id_range = 500;
ConnectionPool pool = new ConnectionPool(host: "localhost", port: 3306, user: "root", db: "ci_p", max:1);

main() async {
  
  for(var i = 1; i < id_range; i++) {
    await http.read(set_url + "$i").then((contents) {
       
        final json = JSON.decode(contents);
        final json_result = json["resultado"];
        insert_data(json_result);

    });
  }
}

insert_data(json_result) async {

  try {
    var query = await pool.prepare('insert into personas (cedula, nombres, apellidoPaterno, apellidoMaterno, nombreCompleto) values (?, ?, ?, ?, ?)');

    print(json_result);

    await query.execute([
      json_result["cedula"], 
      json_result["nombres"], 
      json_result["apellidoPaterno"],
      json_result["apellidoMaterno"],
      json_result["nombreCompleto"],
    ]);

  } catch(e) {
    print(e.toString());
  }
  
}


