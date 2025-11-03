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

@Database(version:1, entities: [Boat, Customer, Car, PurchaseOffer])
abstract class ProjectDatabase extends FloorDatabase {

  BoatDAO get boatDAO;
  CustomerDAO get customerDAO;
  CarDAO get carDAO;
  PurchaseOfferDAO get purchaseOfferDAO;

}

