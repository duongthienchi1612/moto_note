import 'package:uuid/uuid.dart';
import 'dart:convert';

class Accessory {
  String id;
  String name;
  String note;
  int value;
  int destination;

  Accessory({this.id, this.name, this.note, this.value, this.destination});

  factory Accessory.fromJson(Map<String, dynamic> json) {
    return Accessory(
      id: json['id'],
      name: json['name'],
      note: json['note'],
      value: json['value'],
      destination: json['destination'],
    );
  }

  static Map<String, dynamic> toMap(Accessory accessory) => {
        'id': accessory.id,
        'name': accessory.name,
        'note': accessory.note,
        'value': accessory.value,
        'destination': accessory.destination,
      };

  static String encode(List<Accessory> accessories) => json.encode(
        accessories
            .map<Map<String, dynamic>>(
                (accessories) => Accessory.toMap(accessories))
            .toList(),
      );

  static List<Accessory> decode(String accessories) =>
      (json.decode(accessories) as List<dynamic>)
          .map<Accessory>((item) => Accessory.fromJson(item))
          .toList();

  static List<Accessory> getAccessory() {
    var uuid = Uuid();
    return <Accessory>[];
  }
}
