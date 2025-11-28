import 'package:flutter/material.dart';
import '../DAOs/CarDAO.dart';
import '../models/Car.dart';
import '../ProjectDatabase.dart';

/// Page for managing and viewing cars available for sale.
/// This page will support listing, inserting, updating, and viewing details
/// of cars, with full responsive behavior for phone and tablet layouts.
class CarsForSalePage extends StatefulWidget {
  const CarsForSalePage({Key? key}) : super(key: key);

  @override
  State<CarsForSalePage> createState() => CarsForSalePageState();
}

/// State class for the CarsForSalePage.
/// Holds controllers, database access, selected item, and layout logic.
class CarsForSalePageState extends State<CarsForSalePage> {
  /// Data Access Object for performing database operations on Car records.
  late CarDAO carDAO;

  /// List of cars loaded from the database.
  List<Car> cars = [];

  /// Controller for entering the car's manufacturing year.
  final yearController = TextEditingController();

  /// Controller for entering the car's make.
  final makeController = TextEditingController();

  /// Controller for entering the car's model.
  final modelController = TextEditingController();

  /// Controller for entering the car's price.
  final priceController = TextEditingController();

  /// Controller for entering the car's kilometers driven.
  final kmController = TextEditingController();

  /// Stores values from the previous car entry for retrieval.
  Map<String, dynamic>? lastCarData;

  /// The currently selected car, used in tablet or desktop layouts.
  Car? selectedCar;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadLastCarFromPrefs();
  }

  /// Initializes the database, obtains the ProjectDatabase instance,
  /// and assigns the CarDAO used for all car-related operations.
  Future<void> _initDatabase() async {
    final db = await $FloorProjectDatabase
        .databaseBuilder('customer_database.db')
        .build();

    carDAO = db.carDAO;
    await _loadCarsFromDatabase();
  }

  /// Loads all car records from the database and updates the local list.
  Future<void> _loadCarsFromDatabase() async {
    final carList = await carDAO.getAllCars();
    setState(() {
      cars = carList;
    });
  }

  /// Loads stored last-entry car data from encrypted shared preferences.
  Future<void> _loadLastCarFromPrefs() async {}

  /// Determines and returns the appropriate layout depending on screen size.
  /// Phones show either the list or the details page, while tablets show both.
  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 1, child: ListPage()),
          Expanded(flex: 2, child: DetailsPage()),
        ],
      );
    }

    if (selectedCar == null) {
      return ListPage();
    } else {
      return DetailsPage();
    }
  }

  /// Builds the car list section displayed on the left side of tablet layouts,
  /// or as the main page on phones.
  Widget ListPage() {
    return Column(
      children: const [
        Text("Car List", style: TextStyle(fontSize: 18)),
        // ListView will be added here
      ],
    );
  }

  /// Builds the details section for the selected car,
  /// or a placeholder if nothing is selected.
  Widget DetailsPage() {
    if (selectedCar != null) {
      return Column(
        children: const [
          Text("Details", style: TextStyle(fontSize: 18)),
          // Car details UI will go here
        ],
      );
    }

    return const Center(
      child: Text("Details Placeholder", style: TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Car List")),
      body: reactiveLayout(),
    );
  }
}
