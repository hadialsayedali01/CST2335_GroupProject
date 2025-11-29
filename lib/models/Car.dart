import 'package:floor/floor.dart';

@entity
class Car {
  @primaryKey
  final int? id;

  int year;
  String make;
  String model;
  double price;
  double kilometers;

  Car(this.id, this.year, this.make, this.model, this.price, this.kilometers);
}
