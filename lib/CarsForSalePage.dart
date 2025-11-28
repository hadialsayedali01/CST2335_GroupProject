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

  /// Error message displayed below the form when validation fails.
  String formErrorMessage = "";

  /// Encrypted preferences instance used to cache the last entered car.
  final EncryptedSharedPreferences encPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadLastCarFromPrefs();
  }

  @override
  void dispose() {
    yearController.dispose();
    makeController.dispose();
    modelController.dispose();
    priceController.dispose();
    kmController.dispose();
    super.dispose();
  }

  /// Returns true if the layout should be rendered as master–detail.
  bool _isTabletLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return (width > height) && (width > 720);
  }

  /// Clears all form fields and resets the error message.
  void _clearForm() {
    setState(() {
      yearController.text = "";
      makeController.text = "";
      modelController.text = "";
      priceController.text = "";
      kmController.text = "";
      formErrorMessage = "";
    });
  }

  /// Copies the current content of the form into encrypted shared preferences.
  Future<void> _saveLastCarToPrefs() async {
    await encPrefs.setString("last_car_year", yearController.text);
    await encPrefs.setString("last_car_make", makeController.text);
    await encPrefs.setString("last_car_model", modelController.text);
    await encPrefs.setString("last_car_price", priceController.text);
    await encPrefs.setString("last_car_km", kmController.text);
  }

  /// Loads the last saved car from encrypted shared preferences into the form.
  Future<void> _loadLastCarFromPrefs() async {
    final year = await encPrefs.getString("last_car_year");
    final make = await encPrefs.getString("last_car_make");
    final model = await encPrefs.getString("last_car_model");
    final price = await encPrefs.getString("last_car_price");
    final km = await encPrefs.getString("last_car_km");

    setState(() {
      yearController.text = year ?? "";
      makeController.text = make ?? "";
      modelController.text = model ?? "";
      priceController.text = price ?? "";
      kmController.text = km ?? "";
      formErrorMessage = "";
    });
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

  _ParsedCarForm? _validateAndParseForm(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final yearText = yearController.text.trim();
    final makeText = makeController.text.trim();
    final modelText = modelController.text.trim();
    final priceText = priceController.text.trim();
    final kmText = kmController.text.trim();

    // Basic empty-field validation
    if (yearText.isEmpty ||
        makeText.isEmpty ||
        modelText.isEmpty ||
        priceText.isEmpty ||
        kmText.isEmpty) {
      final msg = loc.translate("EmptyFieldsCar") ?? "All fields are required.";
      setState(() {
        formErrorMessage = msg;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }

    // Numeric parsing
    final year = int.tryParse(yearText);
    final price = double.tryParse(priceText);
    final km = double.tryParse(kmText);

    if (year == null ||
        year <= 0 ||
        price == null ||
        price <= 0 ||
        km == null ||
        km < 0) {
      const msg = "Enter valid numeric values.";
      setState(() => formErrorMessage = msg);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(msg)));
      return null;
    }

    formErrorMessage = "";
    return _ParsedCarForm(
      year: year,
      make: makeText,
      model: modelText,
      price: price,
      kilometers: km,
    );
  }

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

  /// Builds the details form section.
  /// If selectedCar == null → Add Mode
  /// If selectedCar != null → Edit Mode
  Widget DetailsPage() {
    final bool editing = selectedCar != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ----------------------------------------------------
            // Load Previous Car
            // ----------------------------------------------------
            ElevatedButton(
              onPressed: _loadLastCarFromPrefs,
              child: const Text("Load Previous Car"),
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // Title
            // ----------------------------------------------------
            Text(
              editing ? "Edit Car" : "Add New Car",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // Fields
            // ----------------------------------------------------
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Year",
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: makeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Make",
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Model",
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Price",
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: kmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Kilometers",
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // Error text
            // ----------------------------------------------------
            if (formErrorMessage.isNotEmpty)
              Text(formErrorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // Buttons
            // ----------------------------------------------------
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                // ADD (only in Add Mode)
                if (!editing)
                  ElevatedButton(
                    onPressed: () => _submitNewCar(context),
                    child: const Text("Add"),
                  ),

                // UPDATE (only in Edit Mode)
                if (editing)
                  ElevatedButton(
                    onPressed: () => _updateSelectedCar(context),
                    child: const Text("Update"),
                  ),

                // DELETE (only in Edit Mode)
                if (editing)
                  ElevatedButton(
                    onPressed: () => _deleteSelectedCar(context),
                    child: const Text("Delete"),
                  ),

                // RESET fields
                ElevatedButton(
                  onPressed: _clearForm,
                  child: const Text("Reset Fields"),
                ),

                // CLOSE form
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCar = null;
                      isCreatingNewCar = false;
                      formErrorMessage = "";
                    });
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ],
        ),
      ),
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

/// Internal helper type representing parsed form values.
class _ParsedCarForm {
  final int year;
  final String make;
  final String model;
  final double price;
  final double kilometers;

  _ParsedCarForm({
    required this.year,
    required this.make,
    required this.model,
    required this.price,
    required this.kilometers,
  });
}
