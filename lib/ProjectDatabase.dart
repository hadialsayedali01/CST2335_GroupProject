import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'models/Boat.dart';
import 'models/Customer.dart';
import 'models/Car.dart';
import 'models/PurchaseOffer.dart';

import 'DAOs/BoatDAO.dart';
import 'DAOs/CustomerDAO.dart';
import 'DAOs/CarDAO.dart';
import 'DAOs/PurchaseOfferDAO.dart';

part 'ProjectDatabase.g.dart';

/// This class outlines the database of the application to be generated.
/// Its four entitites are Boat, Customer, Car and PurchaseOffer.
/// It exposes four Data Access Objects for querying the database in relation to each entity.
@Database(version:1, entities: [Boat, Customer, Car, PurchaseOffer])
abstract class ProjectDatabase extends FloorDatabase {

  /// The Data Access Object for querying the database in relation to boats.
  BoatDAO get boatDAO;
  /// The Data Access Object for querying the database in relation to customers.
  CustomerDAO get customerDAO;
  /// The Data Access Object for querying the database in relation to cars.
  CarDAO get carDAO;
  /// The Data Access Object for querying the database in relation to purchase offers.
  PurchaseOfferDAO get purchaseOfferDAO;

}

