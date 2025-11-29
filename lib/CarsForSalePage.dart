import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../AppLocalizations.dart';
import '../ProjectDatabase.dart';
import '../models/Car.dart';
import '../DAOs/CarDAO.dart';

/// A stateful page that manages the "Cars for Sale" feature.
///
/// This screen allows:
/// - Listing all cars stored in the local Floor database,
/// - Adding new cars,
/// - Updating existing cars,
/// - Deleting cars,
/// - Loading and saving the last entered car fields using encrypted shared preferences,
/// - Responsive layout (master–detail on tablet, single page on phone),
/// - Basic localization of labels and messages using [AppLocalizations].
class CarsForSalePage extends StatefulWidget {
  /// Default constructor for the CarsForSalePage widget.
  const CarsForSalePage({Key? key}) : super(key: key);

  /// Creates the mutable state that holds all logic for this page.
  @override
  State<CarsForSalePage> createState() => CarsForSalePageState();
}

/// State class that contains all UI state, controllers, and database interaction
/// logic for [CarsForSalePage].
class CarsForSalePageState extends State<CarsForSalePage> {
  /// Data Access Object (DAO) used to perform CRUD operations on the Car table.
  late CarDAO carDAO;

  /// This list is used to build the list view on the left (or full screen on mobile).
  List<Car> cars = [];

  /// Indicates whether the user is currently in "create new car" mode.
  /// When true in mobile mode, the UI shows the details form instead of the list.
  bool isCreatingNewCar = false;

  /// Controller for the "Year" text field.
  final TextEditingController yearController = TextEditingController();

  /// Controller for the "Make" text field.
  final TextEditingController makeController = TextEditingController();

  /// Controller for the "Model" text field.
  final TextEditingController modelController = TextEditingController();

  /// Controller for the "Price" text field.
  final TextEditingController priceController = TextEditingController();

  /// Controller for the "Kilometers" text field.
  final TextEditingController kmController = TextEditingController();

  /// Currently selected car from the list.
  /// - If non-null, the details page is in "edit" mode for this car.
  /// - If null and [isCreatingNewCar] is true, the form is used for a new car.
  Car? selectedCar;

  /// Holds the latest form validation error message.
  /// When non-empty, this is rendered as a red error text in the details section.
  String formErrorMessage = "";

  /// Encrypted shared preferences instance used to persist the last entered car fields.
  ///
  /// This allows the user to reload the last entered values even after app restarts.
  final EncryptedSharedPreferences encPrefs = EncryptedSharedPreferences();

  /// Lifecycle method called when the state is first created.
  /// - Initializes the database using [_initDatabase].
  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  /// Lifecycle method called when the state is disposed.
  /// - Disposes all [TextEditingController] instances to free resources.
  @override
  void dispose() {
    yearController.dispose();
    makeController.dispose();
    modelController.dispose();
    priceController.dispose();
    kmController.dispose();
    super.dispose();
  }

  /// Clears all form text fields and resets the error message.
  void _clearForm() {
    // Reset all controller text values to empty strings.
    yearController.text = "";
    makeController.text = "";
    modelController.text = "";
    priceController.text = "";
    kmController.text = "";
    // Also clear any previous validation error message.
    formErrorMessage = "";
  }

  /// Saves the current form values to encrypted shared preferences.
  /// This method is typically called after successfully adding or updating a car.
  Future<void> _saveLastCarToPrefs() async {
    // Persist each individual field with a dedicated key.
    await encPrefs.setString("last_car_year", yearController.text);
    await encPrefs.setString("last_car_make", makeController.text);
    await encPrefs.setString("last_car_model", modelController.text);
    await encPrefs.setString("last_car_price", priceController.text);
    await encPrefs.setString("last_car_km", kmController.text);
  }

  /// Loads the last saved car values from encrypted shared preferences into the form fields.
  /// If a value was not saved previously, the corresponding field is set to an empty string.
  Future<void> _loadLastCarFromPrefs() async {
    // Read previously saved values from encrypted storage.
    final year = await encPrefs.getString("last_car_year");
    final make = await encPrefs.getString("last_car_make");
    final model = await encPrefs.getString("last_car_model");
    final price = await encPrefs.getString("last_car_price");
    final km = await encPrefs.getString("last_car_km");

    // Update state so UI reflects loaded values.
    setState(() {
      yearController.text = year ?? "";
      makeController.text = make ?? "";
      modelController.text = model ?? "";
      priceController.text = price ?? "";
      kmController.text = km ?? "";
      formErrorMessage = "";
    });
  }

  /// Initializes the Floor database and loads all cars into memory.
  /// - Builds the database using [ProjectDatabase].
  /// - Retrieves a [CarDAO] instance.
  /// - Triggers [_loadCarsFromDatabase] to populate [cars].
  Future<void> _initDatabase() async {
    // Build or open the Floor database named 'customer_database.db'.
    final db = await $FloorProjectDatabase
        .databaseBuilder('customer_database.db')
        .build();

    // Obtain the CarDAO implementation generated by Floor.
    carDAO = db.carDAO;
    // Load all existing cars from the database into memory.
    await _loadCarsFromDatabase();
  }

  /// Loads all cars from the database into the [cars] list and refreshes the UI.
  Future<void> _loadCarsFromDatabase() async {
    // Retrieve all cars from the DAO.
    final carList = await carDAO.getAllCars();
    // Update state so the list view rebuilds with the latest data.
    setState(() {
      cars = carList;
    });
  }

  /// Validates and parses the current form values.
  /// - Validates that all fields are non-empty.
  /// - Ensures:
  ///   - Year is between 1900 and (current year + 1),
  ///   - Price is > 0,
  ///   - Kilometers are >= 0.
  /// - On failure:
  ///   - Sets [formErrorMessage],
  ///   - Shows a [SnackBar] with the error message,
  ///   - Returns null.
  /// - On success:
  ///   - Clears [formErrorMessage],
  ///   - Returns a [_ParsedCarForm] with strongly typed values.
  _ParsedCarForm? _validateAndParseForm(BuildContext context) {
    // Read trimmed values from all controllers.
    final yearText = yearController.text.trim();
    final makeText = makeController.text.trim();
    final modelText = modelController.text.trim();
    final priceText = priceController.text.trim();
    final kmText = kmController.text.trim();

    // Check for any empty fields.
    if (yearText.isEmpty ||
        makeText.isEmpty ||
        modelText.isEmpty ||
        priceText.isEmpty ||
        kmText.isEmpty) {
      // Localized message for empty fields.
      final msg = AppLocalizations.of(context)!.translate("EmptyFieldsCar")!;
      formErrorMessage = msg;
      // Show feedback to the user via SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }

    // Try to parse numeric fields.
    final year = int.tryParse(yearText);
    final price = double.tryParse(priceText);
    final km = double.tryParse(kmText);

    // Validate year range: must be realistic and not too far in the future.
    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
      final msg = AppLocalizations.of(context)!.translate("InvalidYear")!;
      formErrorMessage = msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }

    // Validate price as valid.
    if (price == null) {
      final msg = AppLocalizations.of(context)!.translate("InvalidPrice")!;
      formErrorMessage = msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }

    // Validate kilometers as valid.
    if (km == null) {
      final msg = AppLocalizations.of(context)!.translate("InvalidKilometers")!;
      formErrorMessage = msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }

    // Clear previous validation error if everything is valid.
    formErrorMessage = "";

    // Return parsed values wrapped in a helper object.
    return _ParsedCarForm(
      year: year,
      make: makeText,
      model: modelText,
      price: price,
      kilometers: km,
    );
  }

  /// Handles the creation of a new car record from the form and persists it.
  ///
  /// Steps:
  /// 1. Validates and parses the form via [_validateAndParseForm].
  /// 2. Creates a new [Car] instance using the parsed values.
  /// 3. Inserts the car using [carDAO.insertCar].
  /// 4. Saves the form fields to encrypted prefs.
  /// 5. Reloads the list of cars from the database.
  /// 6. Resets state flags and clears the form.
  /// 7. Shows a localized "CarAdded" [SnackBar].
  Future<void> _submitNewCar(BuildContext context) async {
    // Validate and parse form. Abort if invalid.
    final parsed = _validateAndParseForm(context);
    if (parsed == null) return;

    // Create a new Car instance using the static ID counter.
    final newCar = Car(
      null,
      parsed.year,
      parsed.make,
      parsed.model,
      parsed.price,
      parsed.kilometers,
    );

    // Persist the new car in the database.
    await carDAO.insertCar(newCar);
    // Save the last entered values for possible reuse.
    await _saveLastCarToPrefs();
    // Reload the full list of cars so the UI shows the new entry.
    await _loadCarsFromDatabase();

    // // Reset selection and mode to exit the details view.
    // setState(() {
    //   selectedCar = null;
    //   isCreatingNewCar = false;
    // });

    // Clear the form fields.
    _clearForm();

    // Show success feedback.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("CarAdded")!),
      ),
    );
  }

  /// Handles updating the currently selected car using the form values.
  ///
  /// Steps:
  /// 1. Ensures [selectedCar] is not null.
  /// 2. Validates and parses the form.
  /// 3. Prompts the user with a confirmation dialog.
  /// 4. Applies the parsed form values to [selectedCar].
  /// 5. Persists the updated car using [carDAO.updateCar].
  /// 6. Saves the current form values to encrypted preferences.
  /// 7. Reloads the car list from the database.
  /// 8. Displays a localized "CarUpdated" SnackBar.
  Future<void> _updateSelectedCar(BuildContext context) async {
    // If no car is selected, there is nothing to update.
    if (selectedCar == null) return;

    // Validate and parse form. Abort if invalid.
    final parsed = _validateAndParseForm(context);
    if (parsed == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("ConfirmUpdateTitle")!,
        ),
        content: Text(
          AppLocalizations.of(context)!.translate("ConfirmUpdateMessage")!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate("Cancel")!),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.translate("Update")!),
          ),
        ],
      ),
    );

    // User canceled.
    if (confirmed != true) return;

    // Apply the parsed form values to the currently selected car.
    selectedCar!.year = parsed.year;
    selectedCar!.make = parsed.make;
    selectedCar!.model = parsed.model;
    selectedCar!.price = parsed.price;
    selectedCar!.kilometers = parsed.kilometers;

    // Persist the updated car in the database.
    await carDAO.updateCar(selectedCar!);
    // Save current form values to encrypted prefs.
    await _saveLastCarToPrefs();
    // Refresh list to reflect the updated car.
    await _loadCarsFromDatabase();

    // Show success feedback.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("CarUpdated")!),
      ),
    );
  }

  /// Handles deletion of the currently selected car after a confirmation dialog.
  ///
  /// Steps:
  /// 1. Ensures [selectedCar] is not null.
  /// 2. Displays a localized confirmation dialog.
  /// 3. If the user confirms:
  ///    - Deletes the car using [carDAO.deleteCar].
  ///    - Reloads the car list.
  ///    - Resets [selectedCar] and [isCreatingNewCar].
  ///    - Clears the form.
  ///    - Shows a localized "CarDeleted" [SnackBar].
  Future<void> _deleteSelectedCar(BuildContext context) async {
    // If no car is selected, there is nothing to delete.
    if (selectedCar == null) return;

    // Show a confirmation dialog to avoid accidental deletions.
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

    // If user cancels or dismisses dialog, stop here.
    if (confirmed != true) return;

    // Perform the actual delete in the database.
    await carDAO.deleteCar(selectedCar!);
    // Reload cars from database to remove the deleted entry from the UI.
    await _loadCarsFromDatabase();

    // // Clear selection and mode flags.
    // setState(() {
    //   selectedCar = null;
    //   isCreatingNewCar = false;
    // });

    // Clear any form inputs.
    _clearForm();

    // Show success feedback.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("CarDeleted")!),
      ),
    );
  }

  /// Populates the form controllers with the values from the given [car].
  ///
  /// This is called when the user taps on a car in the list to edit its details.
  void _populateFormFromCar(Car car) {
    setState(() {
      // Copy all fields from the selected car into the text controllers.
      yearController.text = car.year.toString();
      makeController.text = car.make;
      modelController.text = car.model;
      priceController.text = car.price.toString();
      kmController.text = car.kilometers.toString();
      // Clear any previous validation error when switching to a new car.
      formErrorMessage = "";
    });
  }

  /// Builds the responsive layout for the page.
  ///
  /// - On tablet (wide landscape), shows a master–detail layout:
  ///   - Left side: list of cars,
  ///   - Right side: details or a "Details" hint when nothing is selected.
  /// - On mobile:
  ///   - Shows either the list or the details page, but not both at the same time.
  Widget reactiveLayout() {
    // Obtain screen size to decide between tablet and phone layout.
    final size = MediaQuery.of(context).size;

    // A simple heuristic: if width > height and width > 720, treat as tablet.
    final bool isTablet = size.width > size.height && size.width > 720;

    if (isTablet) {
      // Tablet mode: show list and detail side by side.
      return Row(
        children: [
          // Left pane: list of cars.
          Expanded(flex: 1, child: ListPage()),
          // Right pane: details if creating or editing, else show a placeholder.
          Expanded(
            flex: 2,
            child: (isCreatingNewCar || selectedCar != null)
                ? DetailsPage()
                : Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate("Details")!,
                    ),
                  ),
          ),
        ],
      );
    }

    // Mobile mode:
    // If the user is creating a new car or editing one, show the details form.
    if (isCreatingNewCar || selectedCar != null) {
      return DetailsPage();
    }

    // Otherwise, show the list view.
    return ListPage();
  }

  /// Builds a styled card representation for a single [car] in the list.
  ///
  /// This method centralizes the visual styling of each list item to keep
  /// the list builder clean.
  Widget _styledListCard(Car car) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main title: Id + Year + Make + Model.
          Text(
            "${car.id}: ${car.year} ${car.make} ${car.model}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          // Subtitle: Price and Kilometers, both localized labels.
          Text(
            "${AppLocalizations.of(context)!.translate("Price")!}: \$${car.price} • "
            "${AppLocalizations.of(context)!.translate("KilometersDriven")!}: ${car.kilometers}",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// Builds a styled text field with a white card-like background and shadow.
  ///
  /// Parameters:
  /// - [controller]: The [TextEditingController] managing the text.
  /// - [label]: Localized label to display in the input decoration.
  /// - [keyboardType]: Type of keyboard to show (defaults to text).
  ///
  /// If [keyboardType] is numeric, an input formatter is applied to restrict
  /// the input to digits and periods.
  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        // Restrict input if numeric keyboard is requested.
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Builds the "list" page that shows all cars and an "Add New Car" button.
  /// On tablet, this is the left pane. On mobile, this takes the full screen
  /// when not in details mode.
  Widget ListPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Button to start creating a new car.
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Clear the current selection and enter creation mode.
                selectedCar = null;
                isCreatingNewCar = true;
                _clearForm();
              });
            },
            child: Text(AppLocalizations.of(context)!.translate("AddNewCar")!),
          ),
          const SizedBox(height: 10),
          // If there are no cars, show a friendly message. Otherwise, show the list.
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
                        // When a car is tapped, populate the form and switch to edit mode.
                        onTap: () {
                          _populateFormFromCar(car);
                          setState(() {
                            selectedCar = car;
                            isCreatingNewCar = false;
                          });
                        },
                        child: _styledListCard(car),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  /// Builds the details page that contains the form for adding or editing a car.
  ///
  /// - Contains:
  ///   - "Load Last Car" button,
  ///   - Dynamic title ("Details" or "Add New Car"),
  ///   - Styled text fields,
  ///   - Validation error messages,
  ///   - Action buttons:
  ///     - Add, Update, Remove, Reset, Close.
  Widget DetailsPage() {
    // Determine whether we are editing an existing car or creating a new one.
    bool editing;
    if (selectedCar != null) {
      // A car has been selected from the list, so the form is in "edit" mode.
      editing = true;
    } else {
      // No car is selected, so the form is in "add new car" mode.
      editing = false;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Button to load the last saved car from encrypted prefs.
            ElevatedButton(
              onPressed: _loadLastCarFromPrefs,
              child: Text(
                AppLocalizations.of(context)!.translate("LoadLastCar")!,
              ),
            ),
            const SizedBox(height: 16),

            // Title changes depending on whether we are editing or adding.
            Text(
              editing
                  ? AppLocalizations.of(context)!.translate("Details")!
                  : AppLocalizations.of(context)!.translate("AddNewCar")!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Year field.
            _styledTextField(
              controller: yearController,
              label: AppLocalizations.of(context)!.translate("Year")!,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Make field.
            _styledTextField(
              controller: makeController,
              label: AppLocalizations.of(context)!.translate("Make")!,
            ),
            const SizedBox(height: 12),

            // Model field.
            _styledTextField(
              controller: modelController,
              label: AppLocalizations.of(context)!.translate("Model")!,
            ),
            const SizedBox(height: 12),

            // Price field.
            _styledTextField(
              controller: priceController,
              label: AppLocalizations.of(context)!.translate("Price")!,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Kilometers field.
            _styledTextField(
              controller: kmController,
              label: AppLocalizations.of(context)!.translate("Kilometers")!,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // If there is a validation error message, show it.
            if (formErrorMessage.isNotEmpty)
              Text(formErrorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),

            // Group of action buttons: Add/Update/Remove/Reset/Close.
            Wrap(
              spacing: 12,
              children: [
                // Add button (only visible when not editing an existing car).
                if (!editing)
                  ElevatedButton(
                    onPressed: () => _submitNewCar(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate("Add")!,
                    ),
                  ),
                // Update button (only visible if a car is selected).
                if (editing)
                  ElevatedButton(
                    onPressed: () => _updateSelectedCar(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate("Update")!,
                    ),
                  ),
                // Remove button (only visible if a car is selected).
                if (editing)
                  ElevatedButton(
                    onPressed: () => _deleteSelectedCar(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate("Remove")!,
                    ),
                  ),
                // Reset button to clear all form fields.
                ElevatedButton(
                  onPressed: _clearForm,
                  child: Text(
                    AppLocalizations.of(context)!.translate("ResetCarFields")!,
                  ),
                ),
                // Close button: exits details mode and returns to the list (on mobile),
                // or simply clears selection in tablet layout.
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

  /// Builds the top-level [Scaffold] for the page, including:
  /// - App bar with title, instructions button, and language toggle buttons,
  /// - Body that is rendered by [reactiveLayout].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Localized page title.
        title: Text(AppLocalizations.of(context)!.translate("CarListTitle")!),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Instructions button: opens a dialog with localized instructions.
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
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
          // English locale switch.
          FilledButton(
            onPressed: () {
              MyApp.setLocale(context, const Locale("en"));
            },
            child: Text(AppLocalizations.of(context)!.translate("English")!),
          ),
          // Arabic locale switch.
          FilledButton(
            onPressed: () {
              MyApp.setLocale(context, const Locale("ar"));
            },
            child: const Text("العربية"),
          ),
        ],
      ),
      // Main body uses a responsive layout.
      body: reactiveLayout(),
    );
  }
}

/// Helper data class that stores parsed form values for a car.
///
/// This is used as a return type of [_validateAndParseForm] to keep
/// parsing and validation separate from the entity model [Car].
class _ParsedCarForm {
  /// Parsed year of manufacture.
  final int year;

  /// Parsed make (manufacturer) of the car.
  final String make;

  /// Parsed model name of the car.
  final String model;

  /// Parsed price of the car.
  final double price;

  /// Parsed number of kilometers driven.
  final double kilometers;

  /// Creates a new [_ParsedCarForm] with all required fields.
  _ParsedCarForm({
    required this.year,
    required this.make,
    required this.model,
    required this.price,
    required this.kilometers,
  });
}
