// token_database_provider.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'token.dart';

class TokenDatabaseProvider {
  late Database _database;

  Future<void> open() async {
    _database = await openDatabase(
      'token_database.db',
      version: 2, // Increment the version number when there's a schema change
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS tokensImported(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, symbol TEXT, address TEXT, decimals TEXT, logoURI TEXT, currentPriceUSD TEXT, changePercent24hr TEXT)',
        );
      },
    );
    print(_database.path.toString());
  }

  Future<void> insertToken(Token token) async {
    await _database.insert(
      'tokensImported',
      token.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> checkTokenByAddress(String address) async {
    // Query the database to get a token by its address
    final List<Map<String, dynamic>> maps = await _database.query(
      'tokensImported',
      where: 'address = ?',
      whereArgs: [address],
    );
    if (maps.isEmpty) {
      return false;
    }
    return true;
  }

  Future<List<Token>> getTokens() async {
    final List<Map<String, dynamic>> maps =
        await _database.query('tokensImported');

    return List.generate(maps.length, (i) {
      return Token(
        id: maps[i]['id'],
        name: maps[i]['name'],
        symbol: maps[i]['symbol'],
        address: maps[i]['address'],
        decimals: maps[i]['decimals'],
        logoURI: maps[i]['logoURI'],
        currentPriceUSD: maps[i]['currentPriceUSD'],
        changePercent24hr: maps[i]['changePercent24hr'],
      );
    });
  }

  Future<void> updateToken(Token token) async {
    await _database.update(
      'tokensImported',
      token.toMap(),
      where: 'id = ?',
      whereArgs: [token.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteToken(int id) async {
    await _database.delete(
      'tokensImported',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
