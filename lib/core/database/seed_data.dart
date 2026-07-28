import 'package:sqflite/sqflite.dart';

import '../../data/sql/categoria_sql.dart';
import '../../models/categoria.dart';
import '../../models/enums.dart';

/// Dados iniciais inseridos na criação do banco.
///
/// Popula um conjunto de categorias comuns de receitas e despesas para que o
/// app já seja utilizável no primeiro acesso. As chaves em [Categoria.icone]
/// correspondem ao catálogo em `CategoriaIcones`.
class SeedData {
  const SeedData._();

  static const List<Categoria> _categoriasPadrao = <Categoria>[
    // Receitas
    Categoria(nome: 'Salário', tipo: TipoLancamento.receita, cor: '#0AA307', icone: 'salario'),
    Categoria(nome: 'Freelance', tipo: TipoLancamento.receita, cor: '#14B8A6', icone: 'trabalho'),
    Categoria(nome: 'Investimentos', tipo: TipoLancamento.receita, cor: '#10B981', icone: 'investimento'),
    Categoria(nome: 'Vendas', tipo: TipoLancamento.receita, cor: '#22C55E', icone: 'vendas'),
    Categoria(nome: 'Outras receitas', tipo: TipoLancamento.receita, cor: '#64748B', icone: 'outros'),

    // Despesas
    Categoria(nome: 'Moradia', tipo: TipoLancamento.despesa, cor: '#3B82F6', icone: 'casa'),
    Categoria(nome: 'Alimentação', tipo: TipoLancamento.despesa, cor: '#F59E0B', icone: 'alimentacao'),
    Categoria(nome: 'Mercado', tipo: TipoLancamento.despesa, cor: '#F97316', icone: 'mercado'),
    Categoria(nome: 'Transporte', tipo: TipoLancamento.despesa, cor: '#6C63FF', icone: 'transporte'),
    Categoria(nome: 'Saúde', tipo: TipoLancamento.despesa, cor: '#EF4444', icone: 'saude'),
    Categoria(nome: 'Educação', tipo: TipoLancamento.despesa, cor: '#0377F2', icone: 'educacao'),
    Categoria(nome: 'Lazer', tipo: TipoLancamento.despesa, cor: '#EC4899', icone: 'lazer'),
    Categoria(nome: 'Contas & Assinaturas', tipo: TipoLancamento.despesa, cor: '#8B5CF6', icone: 'contas'),
    Categoria(nome: 'Cartão de crédito', tipo: TipoLancamento.despesa, cor: '#0F172A', icone: 'cartao'),
    Categoria(nome: 'Outras despesas', tipo: TipoLancamento.despesa, cor: '#94A3B8', icone: 'outros'),
  ];

  static Future<void> inserirCategoriasPadrao(Database db) async {
    final Batch batch = db.batch();
    for (final Categoria categoria in _categoriasPadrao) {
      batch.rawInsert(CategoriaSql.insert, CategoriaSql.insertArgs(categoria));
    }
    await batch.commit(noResult: true);
  }
}
