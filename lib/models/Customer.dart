import 'package:floor/floor.dart';

/// Represents a [Customer] entity in the database.
///
/// This class maps to the 'Customer' table.
@entity
class Customer {
  /// A static counter used for ID generation logic.
  static int ID = 1;

  /// The unique identifier for the customer.
  /// Marked as the primary key.
  @primaryKey
  int id;

  /// The customer's first name.
  String firstName;

  /// The customer's last name.
  String lastName;

  /// The customer's physical mailing address.
  String address;

  /// The customer's date of birth (stored as String).
  String dateOfBirth;

  /// The customer's driver's license number.
  String driversLicense;

  /// Creates a new [Customer] instance.
  ///
  /// Updates the static [ID] counter if the provided [id] is greater than the current counter.
  Customer(
    this.id,
    this.firstName,
    this.lastName,
    this.address,
    this.dateOfBirth,
    this.driversLicense,
  ) {
    if (this.id > ID) {
      ID = this.id + 1;
    }
  }
}
