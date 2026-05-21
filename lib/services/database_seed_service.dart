import 'package:sqflite/sqflite.dart';

import 'database_service.dart';
import 'sign_import_service.dart';

/// Serviço responsável por popular o banco no primeiro uso
class DatabaseSeedService {
  final DatabaseService _databaseService;
  final SignImportService _signImportService;

  DatabaseSeedService({
    DatabaseService? databaseService,
    SignImportService? signImportService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _signImportService = signImportService ?? SignImportService();

  /// Executa o seed apenas se a tabela estiver vazia
  Future<void> seedDatabaseIfEmpty() async {
    final isEmpty = await isDatabaseEmpty();
    if (!isEmpty) return;

    final signs = await _signImportService.loadSignsFromCatalog();
    await _databaseService.insertSignsBatch(signs);
  }

  /// Verifica se a tabela de sinais está vazia
  Future<bool> isDatabaseEmpty() async {
    final Database db = await _databaseService.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseService.tableSign}');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }
}
