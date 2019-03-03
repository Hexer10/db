/// File: main.dart
library jaguar.example.silly;

import 'dart:async';
import 'package:jaguar_reflect/jaguar_reflect.dart';
import 'package:jaguar/jaguar.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import 'package:conn_pool/conn_pool.dart';
import 'package:jaguar_mysql1/jaguar_mysql1.dart';

final mysqlPool = MySqlPool('jaguar_learn',
    password: 'dart_jaguar', minPoolSize: 5, maxPoolSize: 10);


@GenController(path: '/contact')
class ContactsApi {
  @GetJson()
  Future<List<Map>> readAll(Context ctx) async {
    mysql.MySqlConnection db = await mysqlPool.injectInterceptor(ctx);
    List<Map<String, Map<String, dynamic>>> values =
        await db.mappedResultsQuery("SELECT * FROM contacts;");
    return values.map((m) => m.values.first).toList();
  }

  @PostJson()
  Future<List<Map>> create(Context ctx) async {
    Map body = await ctx.bodyAsJsonMap();
    mysql.MySqlConnection db = await mysqlPool.injectInterceptor(ctx);
    List<List<dynamic>> id = await db.query(
        "INSERT INTO contacts (name, age) VALUES ('${body['name']}', ${body['age']}) RETURNING id;");
    if (id.isEmpty || id.first.isEmpty) Response.json(null);
    List<Map<String, Map<String, dynamic>>> values =
        await db.mappedResultsQuery("SELECT * FROM contacts;");
    return values.map((m) => m.values.first).toList();
  }
}

Future<void> setup() async {
  // TODO handle open error
  Connection<mysql.MySqlConnection> conn = await mysqlPool.pool.get();
  mysql.MySqlConnection db = conn.connection;

  try {
    await db.query("CREATE DATABSE jaguar_learn;");
  } catch (e) {} finally {}

  try {
    await db.query("DROP TABLE contacts;");
  } catch (e) {} finally {}

  try {
    await db.query(
        "CREATE TABLE contacts (id SERIAL PRIMARY KEY, name VARCHAR(255), age INT);");
  } catch (e) {} finally {
    if (conn != null) await conn.release();
  }
}

Future<void> main() async {
  await setup();

  final server = new Jaguar(port: 10000);
  server.add(reflect(ContactsApi()));
  server.log.onRecord.listen(print);

  await server.serve(logRequests: true);
}
