import 'package:floor/floor.dart';

/// Represents a [Car] entity in the database.
///
/// This class maps to the 'Car' table.
@entity
class Car {
  /// The unique identifier for the car.
  /// Marked as the primary key.
  @primaryKey
  final int? id;

  /// The manufacturing year of the car.
  int year;

  /// The manufacturer of the car (e.g., Toyota, Ford).
  String make;

  /// The specific model name of the car (e.g., Camry, Mustang).
  String model;

  /// The listing price of the car.
  double price;

  /// The distance the car has traveled in kilometers.
  double kilometers;

  /// Creates a new [Car] instance.
  Car(this.id, this.year, this.make, this.model, this.price, this.kilometers);
}
