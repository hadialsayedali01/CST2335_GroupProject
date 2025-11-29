import 'package:floor/floor.dart';

/// Represents a [PurchaseOffer] entity in the database.
///
/// This class maps to the 'PurchaseOffer' table and links customers to vehicles.
@entity
class PurchaseOffer {
  /// A static counter used for ID generation logic.
  static int ID = 1;

  /// The unique identifier for the offer.
  /// Marked as the primary key.
  @primaryKey
  int id;

  /// The ID of the [Customer] making the offer.
  /// Acts as a Foreign Key to the Customer table.
  int customerID;

  /// The ID of the vehicle (Car or Boat) being bid on.
  int vehicleID;

  /// The monetary amount offered by the customer.
  double offerPrice;

  /// The date the offer was made (stored as String).
  String offerDate;

  /// The current status of the offer (e.g., Pending, Accepted, Rejected).
  String offerStatus;

  /// Creates a new [PurchaseOffer] instance.
  ///
  /// Updates the static [ID] counter if the provided [id] is greater than the current counter.
  PurchaseOffer(
    this.id,
    this.customerID,
    this.vehicleID,
    this.offerPrice,
    this.offerDate,
    this.offerStatus,
  ) {
    if (this.id > ID) {
      ID = this.id + 1;
    }
  }
}
