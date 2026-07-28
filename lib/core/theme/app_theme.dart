import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema visual do aplicativo.
///
/// Construído sobre a paleta e a fonte (Open Sans) da biblioteca `inforvix_ux`,
/// com ajustes para uma aparência moderna, limpa e consistente. O app usa o
/// tema claro, alinhado ao padrão visual dos componentes da biblioteca.
class AppTheme {
  const AppTheme._();

  static const String _fonte = 'Open sans';

  static ThemeData get light {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.superficie,
      onSurface: AppColors.texto,
      error: AppColors.despesa,
    );

    final BorderRadius raio = BorderRadius.circular(14);

    OutlineInputBorder borda(Color cor, double largura) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      fontFamily: _fonte,
      scaffoldBackgroundColor: AppColors.fundo,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.texto,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fonte,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.texto,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: raio,
          side: const BorderSide(color: AppColors.borda),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borda,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        hintStyle: const TextStyle(color: AppColors.textoLeve, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: borda(AppColors.borda, 1),
        enabledBorder: borda(AppColors.borda, 1),
        focusedBorder: borda(AppColors.primary, 1.6),
        errorBorder: borda(AppColors.despesa, 1),
        focusedErrorBorder: borda(AppColors.despesa, 1.6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.superficieAlt,
        selectedColor: AppColors.suave(AppColors.primary, 0.14),
        side: const BorderSide(color: AppColors.borda),
        labelStyle: const TextStyle(
          fontFamily: _fonte,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        elevation: 3,
        height: 66,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.suave(AppColors.primary, 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final bool selecionado = estados.contains(WidgetState.selected);
          return IconThemeData(
            color: selecionado ? AppColors.primary : AppColors.textoSuave,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final bool selecionado = estados.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _fonte,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selecionado ? AppColors.primary : AppColors.textoSuave,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.texto,
        contentTextStyle: const TextStyle(
          fontFamily: _fonte,
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionHandleColor: AppColors.primary,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textoSuave,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
