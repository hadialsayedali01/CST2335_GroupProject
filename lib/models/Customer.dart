import 'package:floor/floor.dart';

@entity
class Customer {

  static int ID = 1;

  @primaryKey
  int id;
  String firstName;
  String lastName;
  String address;
  String dateOfBirth;
  String driversLicense;

  Customer(
      this.id,
      this.firstName,
      this.lastName,
      this.address,
      this.dateOfBirth,
      this.driversLicense
      ){
    if (this.id > ID){
      ID = this.id+1;
    }
  }


}