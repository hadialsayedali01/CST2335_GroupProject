import 'package:floor/floor.dart';
import '../models/Boat.dart';

@dao
abstract class BoatDAO{

  @Query('SELECT * FROM Boat')
  Future<List<Boat>> getAllBoats();

  @Query('SELECT * FROM Boat WHERE id = :id')
  Future<Boat?> getBoatByID(int id);

  @insert
  Future<void> insertBoat(Boat boat);

  @update
  Future<void> updateBoat(Boat boat);

  @delete
  Future<void> deleteBoat(Boat boat);

}