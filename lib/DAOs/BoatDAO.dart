import 'package:floor/floor.dart';
import '../models/Boat.dart';

/// Data Access Object for managing [Boat] entity.
@dao
abstract class BoatDAO {
  /// Retrieves all boats from the database.
  @Query('SELECT * FROM Boat')
  Future<List<Boat>> getAllBoats();

  /// Retrieves a specific boat by its [id].
  @Query('SELECT * FROM Boat WHERE id = :id')
  Future<Boat?> getBoatByID(int id);

  /// Inserts a new [boat] into the database.
  @insert
  Future<void> insertBoat(Boat boat);

  /// Updates an existing [boat] in the database.
  @update
  Future<void> updateBoat(Boat boat);

  /// Deletes a specific [boat] from the database.
  @delete
  Future<void> deleteBoat(Boat boat);
}
