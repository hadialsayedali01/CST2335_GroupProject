import 'package:floor/floor.dart';
import '../models/PurchaseOffer.dart';

@dao
abstract class PurchaseOfferDAO {

  @Query('SELECT * FROM PurchaseOffer')
  Future<List<PurchaseOffer>> getAllPurchaseOffers();

  @Query('SELECT * FROM PurchaseOffer WHERE id = :id')
  Future<PurchaseOffer?> getPurchaseOfferByID(int id);

  @insert
  Future<void> insertPurchaseOffer(PurchaseOffer purchaseOffer);

  @update
  Future<void> updatePurchaseOffer(PurchaseOffer purchaseOffer);

  @delete
  Future<void> deletePurchaseOffer(PurchaseOffer purchaseOffer);
  
}
