import 'package:floor/floor.dart';

@entity
class Car {

  static int ID = 1;

  @primaryKey
  int id;
  int year;
  String make;
  String model;
  double price;
  double kilometers;

  Car(
      this.id,
      this.year,
      this.make,
      this.model,
      this.price,
      this.kilometers
      ){
    if (this.id > ID){
      ID = this.id + 1;
    }
  }


}