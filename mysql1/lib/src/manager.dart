import 'dart:async';

import 'package:conn_pool/conn_pool.dart';
import 'package:mysql1/mysql1.dart';

/// [ConnectionManager] for Postgres database
class MySqlManager extends ConnectionManager<MySqlConnection> {
  /// Hostname of database this connection refers to.
  final String host;

  /// Port of database this connection refers to.
  final int port;

  /// Name of database this connection refers to.
  final String databaseName;

  /// Username for authenticating this connection.
  final String username;

  /// Password for authenticating this connection.
  final String password;

  /// Whether or not this connection should connect securely.
  final bool useSsl;

  /// The amount of time this connection will wait during connecting before
  /// giving up.
  final Duration timeout;

  /// The timezone of this connection for date operations that don't specify a
  /// timezone.

  MySqlManager(
    this.databaseName, {
    this.host: 'localhost',
    this.port: 3306,
    this.username: 'postgres',
    this.password,
    this.useSsl: false,
    this.timeout: const Duration(seconds: 30),
  });

  @override

  /// Opens a new [MySqlConnection]
  Future<MySqlConnection> open() async {
    MySqlConnection conn = MySqlConnection(ConnectionSettings(
        host: host,
        port: port,
        db: databaseName,
        user: username,
        password: password,
        useSSL: useSsl,
        timeout: timeout));
    await conn.connect();
    return conn;
  }

  @override

  /// Closes the [connection]
  Future<void> close(MySqlConnection connection) {
    return connection.close();
  }
}
