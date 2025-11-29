import 'package:floor/floor.dart';
import '../models/PurchaseOffer.dart';

/// Data Access Object for managing [PurchaseOffer] entity.
@dao
abstract class PurchaseOfferDAO {
  /// Retrieves all purchase offers from the database.
  @Query('SELECT * FROM PurchaseOffer')
  Future<List<PurchaseOffer>> getAllPurchaseOffers();

  /// Retrieves a specific purchase offer by its [id].
  @Query('SELECT * FROM PurchaseOffer WHERE id = :id')
  Future<PurchaseOffer?> getPurchaseOfferByID(int id);

  /// Inserts a new [purchaseOffer] into the database.
  @insert
  Future<void> insertPurchaseOffer(PurchaseOffer purchaseOffer);

  /// Updates an existing [purchaseOffer] in the database.
  @update
  Future<void> updatePurchaseOffer(PurchaseOffer purchaseOffer);

  /// Deletes a specific [purchaseOffer] from the database.
  @delete
  Future<void> deletePurchaseOffer(PurchaseOffer purchaseOffer);
}
