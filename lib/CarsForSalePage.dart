import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../AppLocalizations.dart';
import '../ProjectDatabase.dart';
import '../models/Car.dart';
import '../DAOs/CarDAO.dart';

class CarsForSalePage extends StatefulWidget {
  const CarsForSalePage({Key? key}) : super(key: key);

  @override
  State<CarsForSalePage> createState() => CarsForSalePageState();
}

class CarsForSalePageState extends State<CarsForSalePage> {
  late CarDAO carDAO;

  List<Car> cars = [];
  bool isCreatingNewCar = false;

  final TextEditingController yearController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController kmController = TextEditingController();

  Car? selectedCar;
  String formErrorMessage = "";
  final EncryptedSharedPreferences encPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _initDatabase();
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

  void _clearForm() {
    yearController.text = "";
    makeController.text = "";
    modelController.text = "";
    priceController.text = "";
    kmController.text = "";
    formErrorMessage = "";
  }

  Future<void> _saveLastCarToPrefs() async {
    await encPrefs.setString("last_car_year", yearController.text);
    await encPrefs.setString("last_car_make", makeController.text);
    await encPrefs.setString("last_car_model", modelController.text);
    await encPrefs.setString("last_car_price", priceController.text);
    await encPrefs.setString("last_car_km", kmController.text);
  }

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

  Future<void> _initDatabase() async {
    final db = await $FloorProjectDatabase
        .databaseBuilder('customer_database.db')
        .build();

    carDAO = db.carDAO;
    await _loadCarsFromDatabase();
  }

  Future<void> _loadCarsFromDatabase() async {
    final carList = await carDAO.getAllCars();
    setState(() {
      cars = carList;
    });
  }

  _ParsedCarForm? _validateAndParseForm(BuildContext context) {
    final yearText = yearController.text.trim();
    final makeText = makeController.text.trim();
    final modelText = modelController.text.trim();
    final priceText = priceController.text.trim();
    final kmText = kmController.text.trim();

    if (yearText.isEmpty ||
        makeText.isEmpty ||
        modelText.isEmpty ||
        priceText.isEmpty ||
        kmText.isEmpty) {
      final msg = AppLocalizations.of(context)!.translate("EmptyFieldsCar")!;
      formErrorMessage = msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }

    final year = int.tryParse(yearText);
    final price = double.tryParse(priceText);
    final km = double.tryParse(kmText);

    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
      const msg = "Enter a valid year.";
      formErrorMessage = msg;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(msg)));
      return null;
    }

    if (price == null || price <= 0) {
      const msg = "Price must be greater than 0.";
      formErrorMessage = msg;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(msg)));
      return null;
    }

    if (km == null || km < 0) {
      const msg = "Kilometers cannot be negative.";
      formErrorMessage = msg;
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

  Future<void> _submitNewCar(BuildContext context) async {
    final parsed = _validateAndParseForm(context);
    if (parsed == null) return;

    final newCar = Car(
      Car.ID++,
      parsed.year,
      parsed.make,
      parsed.model,
      parsed.price,
      parsed.kilometers,
    );

    await carDAO.insertCar(newCar);
    await _saveLastCarToPrefs();
    await _loadCarsFromDatabase();

    setState(() {
      selectedCar = null;
      isCreatingNewCar = false;
    });

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("CarAdded")!),
      ),
    );
  }

  Future<void> _updateSelectedCar(BuildContext context) async {
    if (selectedCar == null) return;

    final parsed = _validateAndParseForm(context);
    if (parsed == null) return;

    selectedCar!
      ..year = parsed.year
      ..make = parsed.make
      ..model = parsed.model
      ..price = parsed.price
      ..kilometers = parsed.kilometers;

    await carDAO.updateCar(selectedCar!);
    await _saveLastCarToPrefs();
    await _loadCarsFromDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("CarUpdated")!),
      ),
    );
  }

  Future<void> _deleteSelectedCar(BuildContext context) async {
    if (selectedCar == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("DeleteCarConfirmTitle")!,
        ),
        content: Text(
          AppLocalizations.of(context)!.translate("DeleteCarConfirmMessage")!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate("No")!),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.translate("Yes")!),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await carDAO.deleteCar(selectedCar!);
    await _loadCarsFromDatabase();

    setState(() {
      selectedCar = null;
      isCreatingNewCar = false;
    });

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("CarDeleted")!),
      ),
    );
  }

  void _populateFormFromCar(Car car) {
    setState(() {
      yearController.text = car.year.toString();
      makeController.text = car.make;
      modelController.text = car.model;
      priceController.text = car.price.toString();
      kmController.text = car.kilometers.toString();
      formErrorMessage = "";
    });
  }

  Widget reactiveLayout() {
    final size = MediaQuery.of(context).size;
    if (size.width > size.height && size.width > 720) {
      return Row(
        children: [
          Expanded(flex: 1, child: ListPage()),
          Expanded(flex: 2, child: DetailsPage()),
        ],
      );
    }

    return selectedCar == null ? ListPage() : DetailsPage();
  }

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
                _clearForm();
              });
            },
            child: Text(AppLocalizations.of(context)!.translate("AddNewCar")!),
          ),
          const SizedBox(height: 10),
          cars.isEmpty
              ? Text(
                  AppLocalizations.of(context)!.translate("NoCars")!,
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return GestureDetector(
                        onTap: () {
                          _populateFormFromCar(car);
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

  Widget DetailsPage() {
    final editing = selectedCar != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loadLastCarFromPrefs,
              child: Text(
                AppLocalizations.of(context)!.translate("LoadLastCar")!,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              editing
                  ? AppLocalizations.of(context)!.translate("Details")!
                  : AppLocalizations.of(context)!.translate("AddNewCar")!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.translate("Year")!,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: makeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.translate("Make")!,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: modelController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.translate("Model")!,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.translate("Price")!,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: kmController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(
                  context,
                )!.translate("Kilometers")!,
              ),
            ),

            const SizedBox(height: 20),

            if (formErrorMessage.isNotEmpty)
              Text(formErrorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              children: [
                if (!editing)
                  ElevatedButton(
                    onPressed: () => _submitNewCar(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate("Add")!,
                    ),
                  ),
                if (editing)
                  ElevatedButton(
                    onPressed: () => _updateSelectedCar(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate("Update")!,
                    ),
                  ),
                if (editing)
                  ElevatedButton(
                    onPressed: () => _deleteSelectedCar(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate("Remove")!,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _clearForm,
                  child: Text(
                    AppLocalizations.of(context)!.translate("ResetCarFields")!,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCar = null;
                      isCreatingNewCar = false;
                      _clearForm();
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate("Close")!,
                  ),
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("CarListTitle")!),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: [
          // Instructions button
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate("CarInstructionsTitle")!,
                    ),
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate("CarInstructions")!,
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.translate("Close")!,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              AppLocalizations.of(context)!.translate("CarInstructionsTitle")!,
            ),
          ),

          // English
          FilledButton(
            onPressed: () {
              MyApp.setLocale(context, const Locale("en"));
            },
            child: Text(AppLocalizations.of(context)!.translate("English")!),
          ),

          // Arabic (use native name)
          FilledButton(
            onPressed: () {
              MyApp.setLocale(context, const Locale("ar"));
            },
            child: const Text("العربية"),
          ),
        ],
      ),

      body: reactiveLayout(),
    );
  }
}

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
