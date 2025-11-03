import 'package:floor/floor.dart';

@entity
class PurchaseOffer {

  static int ID = 1;

  @primaryKey
  int id;
  int customerID;
  int vehicleID;
  double offerPrice;
  String offerDate;
  String offerStatus;

  PurchaseOffer(
      this.id,
      this.customerID,
      this.vehicleID,
      this.offerPrice,
      this.offerDate,
      this.offerStatus){
    if (this.id > ID){
      ID = this.id + 1;
    }
  }

}