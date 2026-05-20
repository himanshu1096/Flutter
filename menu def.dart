import 'package:equatable/equatable.dart';
import 'field_def.dart';

class MenuDef extends Equatable {
  final String code;
  final String label;
  final String instruction;
  final List<FieldDef> fields;
  final String? memoryBaseAddress;
  final String? description;

  const MenuDef({
    required this.code,
    required this.label,
    required this.instruction,
    required this.fields,
    this.memoryBaseAddress,
    this.description,
  });

  @override
  List<Object?> get props => [code];

  FieldDef? fieldByNum(String num) {
    try { return fields.firstWhere((f) => f.num == num); }
    catch (_) { return null; }
  }
}
