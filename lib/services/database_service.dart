import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sign_model.dart';

/// Serviço para gerenciar o banco de dados local
class DatabaseService {
  static const String _databaseName = 'signwriter.db';
  static const int _databaseVersion = 1;
  
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
    final String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
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
        $columnIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
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
    );
    
    return List.generate(maps.length, (i) {
      return SignModel.fromMap(maps[i]);
    });
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