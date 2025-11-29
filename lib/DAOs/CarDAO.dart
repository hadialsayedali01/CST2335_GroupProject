import 'package:floor/floor.dart';
import '../models/Car.dart';

/// Data Access Object for managing [Car] entity.
@dao
abstract class CarDAO {
  /// Retrieves all cars from the database.
  @Query('SELECT * FROM Car')
  Future<List<Car>> getAllCars();

  /// Retrieves a specific car by its [id].
  @Query('SELECT * FROM Car WHERE id = :id')
  Future<Car?> getCarByID(int id);

  /// Inserts a new [car] into the database.
  @insert
  Future<void> insertCar(Car car);

  /// Updates an existing [car] in the database.
  @update
  Future<void> updateCar(Car car);

  /// Deletes a specific [car] from the database.
  @delete
  Future<void> deleteCar(Car car);
}
