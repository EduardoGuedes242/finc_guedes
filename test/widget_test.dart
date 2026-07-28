// Testes unitários das regras de domínio puras (formatação monetária,
// cálculo de vencimento por competência e mapeamento dos enums).

import 'package:flutter_test/flutter_test.dart';

import 'package:finc_guedes/core/utils/app_date_utils.dart';
import 'package:finc_guedes/core/utils/moeda.dart';
import 'package:finc_guedes/models/enums.dart';

void main() {
  group('Moeda', () {
    test('formata centavos em reais', () {
      expect(Moeda.format(123456), contains('1.234,56'));
      expect(Moeda.format(0), contains('0,00'));
    });

    test('extrai centavos de texto formatado', () {
      expect(MoedaInputFormatter.centavos('1.234,56'), 123456);
      expect(MoedaInputFormatter.centavos(''), 0);
      expect(MoedaInputFormatter.centavos(r'R$ 10,00'), 1000);
    });

    test('ida e volta entre centavos e texto', () {
      expect(
        MoedaInputFormatter.centavos(MoedaInputFormatter.textoDeCentavos(9999)),
        9999,
      );
    });
  });

  group('AppDateUtils.vencimentoNaCompetencia', () {
    test('mantém o dia quando existe no mês', () {
      final venc = AppDateUtils.vencimentoNaCompetencia(DateTime(2026, 7, 1), 10);
      expect(venc, DateTime(2026, 7, 10));
    });

    test('ajusta para o último dia em meses curtos (fev não bissexto)', () {
      final venc = AppDateUtils.vencimentoNaCompetencia(DateTime(2026, 2, 1), 31);
      expect(venc, DateTime(2026, 2, 28));
    });

    test('ajusta para 29 em fevereiro bissexto', () {
      final venc = AppDateUtils.vencimentoNaCompetencia(DateTime(2024, 2, 1), 31);
      expect(venc, DateTime(2024, 2, 29));
    });

    test('próxima competência avança um mês', () {
      expect(
        AppDateUtils.nextCompetencia(DateTime(2026, 12, 1)),
        DateTime(2027, 1, 1),
      );
    });
  });

  group('Enums', () {
    test('TipoLancamento mapeia códigos E/S', () {
      expect(TipoLancamento.fromCode('E'), TipoLancamento.receita);
      expect(TipoLancamento.fromCode('S'), TipoLancamento.despesa);
    });

    test('StatusMovimento mapeia códigos inteiros', () {
      expect(StatusMovimento.fromCode(0), StatusMovimento.pendente);
      expect(StatusMovimento.fromCode(1), StatusMovimento.efetivado);
    });

    test('OrigemMovimento mapeia códigos inteiros', () {
      expect(OrigemMovimento.fromCode(0), OrigemMovimento.manual);
      expect(OrigemMovimento.fromCode(1), OrigemMovimento.recorrencia);
    });
  });
}
