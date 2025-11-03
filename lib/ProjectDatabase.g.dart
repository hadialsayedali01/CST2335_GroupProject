// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProjectDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $ProjectDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $ProjectDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $ProjectDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<ProjectDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorProjectDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $ProjectDatabaseBuilderContract databaseBuilder(String name) =>
      _$ProjectDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $ProjectDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$ProjectDatabaseBuilder(null);
}

class _$ProjectDatabaseBuilder implements $ProjectDatabaseBuilderContract {
  _$ProjectDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $ProjectDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $ProjectDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<ProjectDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ProjectDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ProjectDatabase extends ProjectDatabase {
  _$ProjectDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BoatDAO? _boatDAOInstance;

  CustomerDAO? _customerDAOInstance;

  CarDAO? _carDAOInstance;

  PurchaseOfferDAO? _purchaseOfferDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Boat` (`id` INTEGER NOT NULL, `yearBuilt` INTEGER NOT NULL, `length` REAL NOT NULL, `powerType` TEXT NOT NULL, `price` REAL NOT NULL, `address` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER NOT NULL, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `dateOfBirth` TEXT NOT NULL, `driversLicense` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Car` (`id` INTEGER NOT NULL, `year` INTEGER NOT NULL, `make` TEXT NOT NULL, `model` TEXT NOT NULL, `price` REAL NOT NULL, `kilometers` REAL NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PurchaseOffer` (`id` INTEGER NOT NULL, `customerID` INTEGER NOT NULL, `vehicleID` INTEGER NOT NULL, `offerPrice` REAL NOT NULL, `offerDate` TEXT NOT NULL, `offerStatus` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BoatDAO get boatDAO {
    return _boatDAOInstance ??= _$BoatDAO(database, changeListener);
  }

  @override
  CustomerDAO get customerDAO {
    return _customerDAOInstance ??= _$CustomerDAO(database, changeListener);
  }

  @override
  CarDAO get carDAO {
    return _carDAOInstance ??= _$CarDAO(database, changeListener);
  }

  @override
  PurchaseOfferDAO get purchaseOfferDAO {
    return _purchaseOfferDAOInstance ??=
        _$PurchaseOfferDAO(database, changeListener);
  }
}

class _$BoatDAO extends BoatDAO {
  _$BoatDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _boatInsertionAdapter = InsertionAdapter(
            database,
            'Boat',
            (Boat item) => <String, Object?>{
                  'id': item.id,
                  'yearBuilt': item.yearBuilt,
                  'length': item.length,
                  'powerType': item.powerType,
                  'price': item.price,
                  'address': item.address
                }),
        _boatUpdateAdapter = UpdateAdapter(
            database,
            'Boat',
            ['id'],
            (Boat item) => <String, Object?>{
                  'id': item.id,
                  'yearBuilt': item.yearBuilt,
                  'length': item.length,
                  'powerType': item.powerType,
                  'price': item.price,
                  'address': item.address
                }),
        _boatDeletionAdapter = DeletionAdapter(
            database,
            'Boat',
            ['id'],
            (Boat item) => <String, Object?>{
                  'id': item.id,
                  'yearBuilt': item.yearBuilt,
                  'length': item.length,
                  'powerType': item.powerType,
                  'price': item.price,
                  'address': item.address
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Boat> _boatInsertionAdapter;

  final UpdateAdapter<Boat> _boatUpdateAdapter;

  final DeletionAdapter<Boat> _boatDeletionAdapter;

  @override
  Future<List<Boat>> getAllBoats() async {
    return _queryAdapter.queryList('SELECT * FROM Boat',
        mapper: (Map<String, Object?> row) => Boat(
            row['id'] as int,
            row['yearBuilt'] as int,
            row['length'] as double,
            row['powerType'] as String,
            row['price'] as double,
            row['address'] as String));
  }

  @override
  Future<Boat?> getBoatByID(int id) async {
    return _queryAdapter.query('SELECT * FROM Boat WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Boat(
            row['id'] as int,
            row['yearBuilt'] as int,
            row['length'] as double,
            row['powerType'] as String,
            row['price'] as double,
            row['address'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertBoat(Boat boat) async {
    await _boatInsertionAdapter.insert(boat, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateBoat(Boat boat) async {
    await _boatUpdateAdapter.update(boat, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteBoat(Boat boat) async {
    await _boatDeletionAdapter.delete(boat);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'driversLicense': item.driversLicense
                }),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'driversLicense': item.driversLicense
                }),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'driversLicense': item.driversLicense
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int,
            row['firstName'] as String,
            row['lastName'] as String,
            row['address'] as String,
            row['dateOfBirth'] as String,
            row['driversLicense'] as String));
  }

  @override
  Future<Customer?> getCustomerByID(int id) async {
    return _queryAdapter.query('SELECT * FROM Customer WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int,
            row['firstName'] as String,
            row['lastName'] as String,
            row['address'] as String,
            row['dateOfBirth'] as String,
            row['driversLicense'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertCustomer(Customer customer) async {
    await _customerInsertionAdapter.insert(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customerUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(Customer customer) async {
    await _customerDeletionAdapter.delete(customer);
  }
}

class _$CarDAO extends CarDAO {
  _$CarDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _carInsertionAdapter = InsertionAdapter(
            database,
            'Car',
            (Car item) => <String, Object?>{
                  'id': item.id,
                  'year': item.year,
                  'make': item.make,
                  'model': item.model,
                  'price': item.price,
                  'kilometers': item.kilometers
                }),
        _carUpdateAdapter = UpdateAdapter(
            database,
            'Car',
            ['id'],
            (Car item) => <String, Object?>{
                  'id': item.id,
                  'year': item.year,
                  'make': item.make,
                  'model': item.model,
                  'price': item.price,
                  'kilometers': item.kilometers
                }),
        _carDeletionAdapter = DeletionAdapter(
            database,
            'Car',
            ['id'],
            (Car item) => <String, Object?>{
                  'id': item.id,
                  'year': item.year,
                  'make': item.make,
                  'model': item.model,
                  'price': item.price,
                  'kilometers': item.kilometers
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Car> _carInsertionAdapter;

  final UpdateAdapter<Car> _carUpdateAdapter;

  final DeletionAdapter<Car> _carDeletionAdapter;

  @override
  Future<List<Car>> getAllCars() async {
    return _queryAdapter.queryList('SELECT * FROM Car',
        mapper: (Map<String, Object?> row) => Car(
            row['id'] as int,
            row['year'] as int,
            row['make'] as String,
            row['model'] as String,
            row['price'] as double,
            row['kilometers'] as double));
  }

  @override
  Future<Car?> getCarByID(int id) async {
    return _queryAdapter.query('SELECT * FROM Car WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Car(
            row['id'] as int,
            row['year'] as int,
            row['make'] as String,
            row['model'] as String,
            row['price'] as double,
            row['kilometers'] as double),
        arguments: [id]);
  }

  @override
  Future<void> insertCar(Car car) async {
    await _carInsertionAdapter.insert(car, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCar(Car car) async {
    await _carUpdateAdapter.update(car, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCar(Car car) async {
    await _carDeletionAdapter.delete(car);
  }
}

class _$PurchaseOfferDAO extends PurchaseOfferDAO {
  _$PurchaseOfferDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _purchaseOfferInsertionAdapter = InsertionAdapter(
            database,
            'PurchaseOffer',
            (PurchaseOffer item) => <String, Object?>{
                  'id': item.id,
                  'customerID': item.customerID,
                  'vehicleID': item.vehicleID,
                  'offerPrice': item.offerPrice,
                  'offerDate': item.offerDate,
                  'offerStatus': item.offerStatus
                }),
        _purchaseOfferUpdateAdapter = UpdateAdapter(
            database,
            'PurchaseOffer',
            ['id'],
            (PurchaseOffer item) => <String, Object?>{
                  'id': item.id,
                  'customerID': item.customerID,
                  'vehicleID': item.vehicleID,
                  'offerPrice': item.offerPrice,
                  'offerDate': item.offerDate,
                  'offerStatus': item.offerStatus
                }),
        _purchaseOfferDeletionAdapter = DeletionAdapter(
            database,
            'PurchaseOffer',
            ['id'],
            (PurchaseOffer item) => <String, Object?>{
                  'id': item.id,
                  'customerID': item.customerID,
                  'vehicleID': item.vehicleID,
                  'offerPrice': item.offerPrice,
                  'offerDate': item.offerDate,
                  'offerStatus': item.offerStatus
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PurchaseOffer> _purchaseOfferInsertionAdapter;

  final UpdateAdapter<PurchaseOffer> _purchaseOfferUpdateAdapter;

  final DeletionAdapter<PurchaseOffer> _purchaseOfferDeletionAdapter;

  @override
  Future<List<PurchaseOffer>> getAllPurchaseOffers() async {
    return _queryAdapter.queryList('SELECT * FROM PurchaseOffer',
        mapper: (Map<String, Object?> row) => PurchaseOffer(
            row['id'] as int,
            row['customerID'] as int,
            row['vehicleID'] as int,
            row['offerPrice'] as double,
            row['offerDate'] as String,
            row['offerStatus'] as String));
  }

  @override
  Future<PurchaseOffer?> getPurchaseOfferByID(int id) async {
    return _queryAdapter.query('SELECT * FROM PurchaseOffer WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PurchaseOffer(
            row['id'] as int,
            row['customerID'] as int,
            row['vehicleID'] as int,
            row['offerPrice'] as double,
            row['offerDate'] as String,
            row['offerStatus'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertPurchaseOffer(PurchaseOffer purchaseOffer) async {
    await _purchaseOfferInsertionAdapter.insert(
        purchaseOffer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePurchaseOffer(PurchaseOffer purchaseOffer) async {
    await _purchaseOfferUpdateAdapter.update(
        purchaseOffer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePurchaseOffer(PurchaseOffer purchaseOffer) async {
    await _purchaseOfferDeletionAdapter.delete(purchaseOffer);
  }
}
