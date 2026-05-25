import 'package:sqflite/sqflite.dart';

import '../models/sign_model.dart';
import '../models/text_document_model.dart';
import '../models/written_sign_model.dart';

/// Serviço para gerenciar o banco de dados local
class DatabaseService {
  static const String _databaseName = 'signwriter.db';
  static const int _databaseVersion = 5;
  
  // Nomes das tabelas
  static const String tableSign = 'signs';
  
  // Colunas da tabela signs
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnSignImagePath = 'sign_image_path';
  static const String columnVideoPath = 'video_path';
  static const String columnCategory = 'category';
  static const String columnCreatedAt = 'created_at';
  static const String columnIsFavorite = 'is_favorite';
  static const String columnTags = 'tags';
  static const String columnSignWritingCode = 'sign_writing_code';
  static const String columnPortugueseText = 'portuguese_text';

  // Tabela de traduções
  static const String tableTranslation = 'translations';
  static const String columnTranslationId = 'id';
  static const String columnSourceText = 'source_text';
  static const String columnSignIds = 'sign_ids';
  static const String columnNotFoundWords = 'not_found_words';
  static const String columnSignWritingSequence = 'sign_writing_sequence';
  static const String columnTranslationCreatedAt = 'created_at';
  static const String columnTranslationIsFavorite = 'is_favorite';

  // Tabela de documentos de texto
  static const String tableTextDocument = 'text_documents';
  static const String columnTextDocumentId = 'id';
  static const String columnTextDocumentTitle = 'title';
  static const String columnTextDocumentSignIds = 'sign_ids';
  static const String columnTextDocumentCreatedAt = 'created_at';
  static const String columnTextDocumentUpdatedAt = 'updated_at';
  static const String columnTextDocumentIsFavorite = 'is_favorite';

  // Tabela de sinais escritos pelo usuário
  static const String tableWrittenSign = 'written_signs';
  static const String columnWrittenSignUserId = 'user_id';
  static const String columnWrittenSignTitle = 'title';
  static const String columnWrittenSignGlossPt = 'gloss_pt';
  static const String columnWrittenSignLayoutJson = 'layout_json';
  static const String columnWrittenSignPreviewSvg = 'preview_svg';
  static const String columnWrittenSignStatus = 'status';
  static const String columnWrittenSignUpdatedAt = 'updated_at';
  static const String columnWrittenSignPublishedAt = 'published_at';
  
  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  Database? _database;
  
  /// Inicializa e retorna a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final String path = '$databasesPath/$_databaseName';
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Cria as tabelas do banco de dados
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSign (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT,
        $columnSignImagePath TEXT NOT NULL,
        $columnVideoPath TEXT,
        $columnCategory TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnIsFavorite INTEGER NOT NULL DEFAULT 0,
        $columnTags TEXT,
        $columnSignWritingCode TEXT,
        $columnPortugueseText TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTranslation (
        $columnTranslationId TEXT PRIMARY KEY,
        $columnSourceText TEXT NOT NULL,
        $columnSignIds TEXT,
        $columnNotFoundWords TEXT,
        $columnSignWritingSequence TEXT,
        $columnTranslationCreatedAt TEXT NOT NULL,
        $columnTranslationIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTextDocument (
        $columnTextDocumentId TEXT PRIMARY KEY,
        $columnTextDocumentTitle TEXT NOT NULL,
        $columnTextDocumentSignIds TEXT NOT NULL,
        $columnTextDocumentCreatedAt TEXT NOT NULL,
        $columnTextDocumentUpdatedAt TEXT,
        $columnTextDocumentIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableWrittenSign (
        $columnId TEXT PRIMARY KEY,
        $columnWrittenSignUserId TEXT NOT NULL,
        $columnWrittenSignTitle TEXT NOT NULL,
        $columnWrittenSignGlossPt TEXT NOT NULL,
        $columnDescription TEXT,
        $columnCategory TEXT NOT NULL,
        $columnTags TEXT,
        fsw TEXT,
        $columnWrittenSignLayoutJson TEXT NOT NULL,
        $columnWrittenSignPreviewSvg TEXT,
        $columnWrittenSignStatus TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnWrittenSignUpdatedAt TEXT NOT NULL,
        $columnWrittenSignPublishedAt TEXT
      )
    ''');

    await _createIndexes(db);
    await _createWrittenSignsIndexes(db);
  }

  /// Aplica migrações quando a versão do banco é atualizada
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateFromV1ToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateFromV2ToV3(db);
    }
    if (oldVersion < 4) {
      await _migrateFromV3ToV4(db);
    }
    if (oldVersion < 5) {
      await _migrateFromV4ToV5(db);
    }
  }

  /// Migração da versão 1 para a 2
  Future<void> _migrateFromV1ToV2(Database db) async {
    await db.execute('ALTER TABLE $tableSign ADD COLUMN $columnTags TEXT');
    await db.execute('ALTER TABLE $tableSign ADD COLUMN $columnSignWritingCode TEXT');
    await db.execute('ALTER TABLE $tableSign ADD COLUMN $columnPortugueseText TEXT');
    await _createIndexes(db);
  }

  /// Migração da versão 2 para a 3
  Future<void> _migrateFromV2ToV3(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTranslation (
        $columnTranslationId TEXT PRIMARY KEY,
        $columnSourceText TEXT NOT NULL,
        $columnSignIds TEXT,
        $columnNotFoundWords TEXT,
        $columnSignWritingSequence TEXT,
        $columnTranslationCreatedAt TEXT NOT NULL,
        $columnTranslationIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Migração da versão 3 para a 4
  Future<void> _migrateFromV3ToV4(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTextDocument (
        $columnTextDocumentId TEXT PRIMARY KEY,
        $columnTextDocumentTitle TEXT NOT NULL,
        $columnTextDocumentSignIds TEXT NOT NULL,
        $columnTextDocumentCreatedAt TEXT NOT NULL,
        $columnTextDocumentUpdatedAt TEXT,
        $columnTextDocumentIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Migração da versão 4 para a 5
  Future<void> _migrateFromV4ToV5(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableWrittenSign (
        $columnId TEXT PRIMARY KEY,
        $columnWrittenSignUserId TEXT NOT NULL,
        $columnWrittenSignTitle TEXT NOT NULL,
        $columnWrittenSignGlossPt TEXT NOT NULL,
        $columnDescription TEXT,
        $columnCategory TEXT NOT NULL,
        $columnTags TEXT,
        fsw TEXT,
        $columnWrittenSignLayoutJson TEXT NOT NULL,
        $columnWrittenSignPreviewSvg TEXT,
        $columnWrittenSignStatus TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnWrittenSignUpdatedAt TEXT NOT NULL,
        $columnWrittenSignPublishedAt TEXT
      )
    ''');
    await _createWrittenSignsIndexes(db);
  }

  /// Cria índices para melhorar performance de busca
  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_signs_category ON $tableSign($columnCategory)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_signs_name ON $tableSign($columnName)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_signs_tags ON $tableSign($columnTags)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_translations_created_at ON $tableTranslation($columnTranslationCreatedAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_text_documents_created_at ON $tableTextDocument($columnTextDocumentCreatedAt)');
  }

  Future<void> _createWrittenSignsIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_written_signs_status ON $tableWrittenSign($columnWrittenSignStatus)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_written_signs_updated_at ON $tableWrittenSign($columnWrittenSignUpdatedAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_written_signs_title ON $tableWrittenSign($columnWrittenSignTitle)');
  }
  
  /// Insere um sinal no banco de dados
  Future<void> insertSign(SignModel sign) async {
    final Database db = await database;
    
    await db.insert(
      tableSign,
      sign.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insere vários sinais em lote para melhor performance
  Future<void> insertSignsBatch(List<SignModel> signs) async {
    if (signs.isEmpty) return;
    final Database db = await database;
    final batch = db.batch();

    for (final sign in signs) {
      batch.insert(
        tableSign,
        sign.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
  
  /// Atualiza um sinal no banco de dados
  Future<void> updateSign(SignModel sign) async {
    final Database db = await database;
    
    await db.update(
      tableSign,
      sign.toMap(),
      where: '$columnId = ?',
      whereArgs: [sign.id],
    );
  }
  
  /// Busca todos os sinais do banco de dados
  Future<List<SignModel>> getSigns() async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(tableSign);
    
    return List.generate(maps.length, (i) {
      return SignModel.fromMap(maps[i]);
    });
  }
  
  /// Busca sinais por categoria
  Future<List<SignModel>> getSignsByCategory(String category) async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableSign,
      where: '$columnCategory = ?',
      whereArgs: [category],
      orderBy: '$columnName ASC',
    );
    
    return List.generate(maps.length, (i) {
      return SignModel.fromMap(maps[i]);
    });
  }

  /// Busca sinais por tag (tags armazenadas em JSON)
  Future<List<SignModel>> getSignsByTag(String tag) async {
    final Database db = await database;
    final searchTerm = '%$tag%';
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM $tableSign
      WHERE $columnTags LIKE ? COLLATE NOCASE
      ORDER BY $columnName ASC
      ''',
      [searchTerm],
    );

    return maps.map((map) => SignModel.fromMap(map)).toList();
  }

  /// Busca sinais por múltiplas tags (qualquer uma)
  Future<List<SignModel>> getSignsByTags(List<String> tags) async {
    if (tags.isEmpty) return [];
    final Database db = await database;
    final placeholders = List.filled(tags.length, '$columnTags LIKE ? COLLATE NOCASE').join(' OR ');
    final searchTerms = tags.map((tag) => '%$tag%').toList();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT * FROM $tableSign
      WHERE $placeholders
      ORDER BY $columnName ASC
      ''',
      searchTerms,
    );

    return maps.map((map) => SignModel.fromMap(map)).toList();
  }

  /// Busca geral por nome, descrição e tags
  Future<List<SignModel>> searchSigns(String query) async {
    final Database db = await database;
    final searchTerm = '%$query%';
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM $tableSign
      WHERE $columnName LIKE ? COLLATE NOCASE
         OR $columnDescription LIKE ? COLLATE NOCASE
         OR $columnTags LIKE ? COLLATE NOCASE
      ORDER BY
        CASE
          WHEN $columnName LIKE ? COLLATE NOCASE THEN 1
          WHEN $columnTags LIKE ? COLLATE NOCASE THEN 2
          ELSE 3
        END,
        $columnName ASC
      LIMIT 50
      ''',
      [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm],
    );

    return maps.map((map) => SignModel.fromMap(map)).toList();
  }

  /// Alterna um sinal como favorito
  Future<void> toggleSignFavorite(String signId, bool isFavorite) async {
    final Database db = await database;
    await db.update(
      tableSign,
      {columnIsFavorite: isFavorite ? 1 : 0},
      where: '$columnId = ?',
      whereArgs: [signId],
    );
  }

  /// Busca todos os sinais favoritos
  Future<List<SignModel>> getFavoriteSigns() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSign,
      where: '$columnIsFavorite = ?',
      whereArgs: [1],
      orderBy: '$columnName ASC',
    );

    return maps.map((map) => SignModel.fromMap(map)).toList();
  }

  /// Busca sinais por uma lista de IDs
  Future<List<SignModel>> getSignsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final Database db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final maps = await db.rawQuery(
      'SELECT * FROM $tableSign WHERE $columnId IN ($placeholders)',
      ids,
    );
    return maps.map((map) => SignModel.fromMap(map)).toList();
  }

  /// Salva uma tradução
  Future<void> saveTranslation(Map<String, dynamic> data) async {
    final Database db = await database;
    await db.insert(
      tableTranslation,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca traduções recentes
  Future<List<Map<String, dynamic>>> getRecentTranslations({int limit = 10}) async {
    final Database db = await database;
    return db.query(
      tableTranslation,
      orderBy: '$columnTranslationCreatedAt DESC',
      limit: limit,
    );
  }

  /// Alterna favorito de uma tradução
  Future<void> toggleTranslationFavorite(String translationId, bool isFavorite) async {
    final Database db = await database;
    await db.update(
      tableTranslation,
      {columnTranslationIsFavorite: isFavorite ? 1 : 0},
      where: '$columnTranslationId = ?',
      whereArgs: [translationId],
    );
  }

  /// Salva um documento de texto
  Future<void> saveTextDocument(TextDocumentModel document) async {
    final Database db = await database;
    await db.insert(
      tableTextDocument,
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca todos os documentos de texto
  Future<List<TextDocumentModel>> getAllTextDocuments() async {
    final Database db = await database;
    final maps = await db.query(
      tableTextDocument,
      orderBy: '$columnTextDocumentCreatedAt DESC',
    );
    return maps.map((map) => TextDocumentModel.fromMap(map)).toList();
  }

  /// Busca um documento pelo ID
  Future<TextDocumentModel?> getTextDocumentById(String id) async {
    final Database db = await database;
    final maps = await db.query(
      tableTextDocument,
      where: '$columnTextDocumentId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TextDocumentModel.fromMap(maps.first);
  }

  /// Atualiza um documento de texto
  Future<void> updateTextDocument(TextDocumentModel document) async {
    final Database db = await database;
    await db.update(
      tableTextDocument,
      document.toMap(),
      where: '$columnTextDocumentId = ?',
      whereArgs: [document.id],
    );
  }

  /// Remove um documento de texto
  Future<void> deleteTextDocument(String id) async {
    final Database db = await database;
    await db.delete(
      tableTextDocument,
      where: '$columnTextDocumentId = ?',
      whereArgs: [id],
    );
  }

  /// Salva um sinal autoral do usuário.
  Future<void> saveWrittenSign(WrittenSignModel sign) async {
    final Database db = await database;
    await db.insert(
      tableWrittenSign,
      sign.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca todos os sinais autorais salvos localmente.
  Future<List<WrittenSignModel>> getWrittenSigns() async {
    final Database db = await database;
    final maps = await db.query(
      tableWrittenSign,
      orderBy: '$columnWrittenSignUpdatedAt DESC',
    );
    return maps.map((map) => WrittenSignModel.fromMap(map)).toList();
  }

  /// Remove um sinal autoral salvo localmente.
  Future<void> deleteWrittenSign(String id) async {
    final Database db = await database;
    await db.delete(
      tableWrittenSign,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  
  /// Busca um sinal pelo ID
  Future<SignModel?> getSignById(String id) async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableSign,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return SignModel.fromMap(maps.first);
    }
    
    return null;
  }
  
  /// Exclui um sinal do banco de dados
  Future<void> deleteSign(String id) async {
    final Database db = await database;
    
    await db.delete(
      tableSign,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  
  /// Fecha a conexão com o banco de dados
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}