import 'package:flutter/material.dart';
import '../DAOs/CarDAO.dart';
import '../models/Car.dart';
import '../AppLocalizations.dart';

/// The main page for the Cars For Sale module.
/// This widget will later support listing cars, adding new entries,
/// updating/deleting existing cars, showing details, and supporting
/// localization, dialogs, encrypted preferences, and tablet layouts.
class CarsForSalePage extends StatefulWidget {
  @override
  State<CarsForSalePage> createState() => CarsForSalePageState();
}

/// State class for the CarsForSalePage.
class CarsForSalePageState extends State<CarsForSalePage> {
  /// Data Access Object for the Car table.
  late CarDAO carDAO;

  /// List storing all cars loaded from the database.
  /// This list will populate the ListView once loaded.
  List<Car> cars = [];

  /// Controller for the Year input field.
  final yearController = TextEditingController();

  /// Controller for the Make input field.
  final makeController = TextEditingController();

  /// Controller for the Model input field.
  final modelController = TextEditingController();

  /// Controller for the Price input field.
  final priceController = TextEditingController();

  /// Controller for the Kilometers input field.
  final kmController = TextEditingController();

  /// Stores last entered car values for the "Copy Previous Car" feature.
  Map<String, dynamic>? lastCarData;

  /// The car currently selected in tablet/desktop mode.
  /// Used only when the layout is wide enough for two-pane display.
  Car? selectedCar;

  /// Indicates whether the screen width is large enough for two-pane layout.
  bool isWide = false;

  /// Localization reference for translating UI text.
  AppLocalizations? tr;

  @override
  Widget build(BuildContext context) {
    // Localization binding for this build.
    tr = AppLocalizations.of(context);

    // Detect whether we are in tablet/desktop mode.
    isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: Text(tr?.translate("CarListTitle") ?? "Car List")),

      // Temporary placeholder body.
      // Later branches will replace this with list and detail layouts.
      body: Center(
        child: Text(
          tr?.translate("Details") ?? "Details Placeholder",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
