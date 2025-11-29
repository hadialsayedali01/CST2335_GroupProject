import 'package:floor/floor.dart';

/// Represents a [Boat] entity in the database.
///
/// This class maps to the 'Boat' table.
@entity
class Boat {
  /// A static counter used for ID generation logic.
  static int ID = 1;

  /// The unique identifier for the boat.
  /// Marked as the primary key.
  @primaryKey
  int id;

  /// The year the boat was built.
  int yearBuilt;

  /// The length of the boat in feet or meters.
  double length;

  /// The type of power used by the boat (e.g., Sail, Motor, Gas).
  String powerType;

  /// The listing price of the boat.
  double price;

  /// The physical location/address where the boat is stored.
  String address;

  /// Creates a new [Boat] instance.
  ///
  /// Updates the static [ID] counter if the provided [id] is greater than the current counter.
  Boat(
    this.id,
    this.yearBuilt,
    this.length,
    this.powerType,
    this.price,
    this.address,
  ) {
    if (this.id > ID) {
      ID = this.id + 1;
    }
  }
}
