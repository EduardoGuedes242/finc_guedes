import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_schema.dart';
import 'seed_data.dart';

/// Ponto único de acesso à conexão SQLite.
///
/// Responsável apenas por abrir/configurar/criar o banco. Todas as consultas
/// ficam nos repositórios. A instância do [Database] é aberta de forma
/// preguiçosa e reutilizada durante todo o ciclo de vida do app.
class AppDatabase {
  AppDatabase._();

  /// Instância única.
  static final AppDatabase instance = AppDatabase._();

  static const String _fileName = 'finc_guedes.db';

  Database? _db;

  /// Retorna a conexão aberta, abrindo-a na primeira chamada.
  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final String dir = await getDatabasesPath();
    final String path = p.join(dir, _fileName);
    return openDatabase(
      path,
      version: DatabaseSchema.version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  /// Executado a cada abertura: habilita a verificação de chaves estrangeiras
  /// (desligada por padrão no SQLite).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Criação inicial: cria o schema exatamente como em `ESTRUTURA_BANCO.txt` e
  /// popula as categorias padrão.
  Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();
    for (final String statement in DatabaseSchema.createStatements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);

    await SeedData.inserirCategoriasPadrao(db);
  }

  /// Fecha a conexão (útil em testes).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
