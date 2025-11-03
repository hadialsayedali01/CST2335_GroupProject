import 'package:floor/floor.dart';

@entity
class Boat {

  static int ID = 1;

  @primaryKey
  int id;
  int yearBuilt;
  double length;
  String powerType;
  double price;
  String address;

  Boat(
      this.id,
      this.yearBuilt,
      this.length,
      this.powerType,
      this.price,
      this.address
      ){
    if (this.id > ID){
      ID = this.id + 1;
    }
  }


}