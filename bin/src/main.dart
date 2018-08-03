import 'package:dart_set_scraper/dart_set_scraper.dart' as dart_set_scraper;
import 'dart:async';
import 'dart:convert';
import 'package:sqljocky/sqljocky.dart';
import 'package:http/http.dart' as http;

String set_url = "https://servicios.set.gov.py/eset-publico/ciudadano/recuperar?cedula=";
int id_range = 600;
ConnectionPool pool;
int threads = 15;
bool use_mysql = false;

main() async {

  if(use_mysql) {
    pool = new ConnectionPool(host: "localhost", port: 3306, user: "root", db: "ci_paraguay", max:1);
  }
  
  if (id_range % threads != 0) {
    print("threads must be a factor of id_range");
    return;
  }

  var max_thread_requests = (id_range / threads).round();
  var thread_start = 0;

  for(var i = 0; i < id_range; i++) {
    if(i == thread_start) {
      thread_start += (max_thread_requests);
      start_thread(i + 1,(id_range - (id_range - thread_start)));
    } 
  }
}

start_thread(start, end) async {

  for(var i = start; i < end; i++) {
    await http.read(set_url + "$i").then((contents) {
       
        final json = JSON.decode(contents);
        final json_result = json["resultado"];
        print(json_result);

        if(use_mysql) {
          insert_data(json_result);
        }
    });
  }
}

insert_data(json_result) async {

  try {
    var query = await pool.prepare('insert into personas (cedula, nombres, apellidoPaterno, apellidoMaterno, nombreCompleto) values (?, ?, ?, ?, ?)');
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


