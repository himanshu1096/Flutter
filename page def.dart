import 'package:equatable/equatable.dart';
import 'menu_def.dart';

/// No `name` field — tabs show P1..P10 only
class PageDef extends Equatable {
  final String label; // "P1".."P10"
  final List<MenuDef> menus;
  const PageDef({required this.label, required this.menus});

  @override
  List<Object?> get props => [label];

  MenuDef? menuByCode(String code) {
    try { return menus.firstWhere((m) => m.code == code); }
    catch (_) { return null; }
  }
}
