import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

import '../AppLocalizations.dart';
import '../ProjectDatabase.dart';
import '../main.dart';
import '../models/Car.dart';
import '../DAOs/CarDAO.dart';

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

  /// Indicates that the form is currently being used to create a new car.
  bool isCreatingNewCar = false;

  /// Controller for the year text field.
  final TextEditingController yearController = TextEditingController();

  /// Controller for the make text field.
  final TextEditingController makeController = TextEditingController();

  /// Controller for the model text field.
  final TextEditingController modelController = TextEditingController();

  /// Controller for the price text field.
  final TextEditingController priceController = TextEditingController();

  /// Controller for the kilometers text field.
  final TextEditingController kmController = TextEditingController();

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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedCar = null;
                isCreatingNewCar = true;
              });
            },
            child: const Text("Add New Car"),
          ),
          const SizedBox(height: 10),
          cars.isEmpty
              ? const Text(
                  "There are no cars in the list",
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCar = car;
                            isCreatingNewCar = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Text(
                            "${index + 1}: ${car.year} ${car.make} ${car.model}  \$${car.price}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
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
