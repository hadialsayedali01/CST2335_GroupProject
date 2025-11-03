import 'package:floor/floor.dart';
import '../models/Car.dart';

@dao
abstract class CarDAO{

  @Query('SELECT * FROM Car')
  Future<List<Car>> getAllCars();

  @Query('SELECT * FROM Car WHERE id = :id')
  Future<Car?> getCarByID(int id);

  @insert
  Future<void> insertCar(Car car);

  @update
  Future<void> updateCar(Car car);

  @delete
  Future<void> deleteCar(Car car);

}