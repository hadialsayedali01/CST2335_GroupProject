import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'ProjectDatabase.dart';
import 'main.dart';
import 'models/PurchaseOffer.dart';
import 'DAOs/PurchaseOfferDAO.dart';

/// An extension of StatefulWidget, PurchaseOfferPage creates a presentation for
/// the Purchase Offer page requirement of the CST2335 Final Project F2025.
/// It presents several text fields for a user to fill out,
/// a button for them to submit this info to the Purchase Offer DB,
/// and the ability to view, update, and delete in-detail information on any
/// entries in the PO DB.
/// All messages or text presented to the user are available to be translated
/// to American English.
/// @author Tyler Hewitt
class PurchaseOfferPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PurchaseOfferPageState();
  }

}

/// The class that establishes the state of the PurchaseOfferPage.
/// It holds the instance variables for the project, constructors, methods, and
/// inner classes that create the visual elements and functionality of the
/// Purchase Offer requirement.
class PurchaseOfferPageState extends State<PurchaseOfferPage> {

  /// TextStyle font applied to any titles.
  var titleFontStyle = TextStyle(fontSize: 20);
  /// TextStyle font applied to any buttons.
  var buttonFontStyle = TextStyle(fontSize: 15, color: Colors.black);
  /// TextStyle font applied to anything else.
  var myFontStyle = TextStyle(fontSize: 18);

  /// Constructor for the PurchaseOfferDAO, to access the POs stored in the DB.
  late PurchaseOfferDAO purchaseOfferDAO;

  /// A List of PurchaseOffer that will store the offers created on this page.
  List<PurchaseOffer> offers = [];

  /// A nullable instance of PurchaseOffer, meant to be selected for
  /// viewing by the user.
  PurchaseOffer? selectedPurchaseOffer;

  /// Constructor for EncryptedSharedPreferences used to store the
  /// previously-entered values of the text fields.
  final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

  /// Controller for the CustomerID text field.
  final TextEditingController customerIdController = TextEditingController();

  /// Controller for the VehicleID text field.
  final TextEditingController vehicleIdController = TextEditingController();

  /// Controller for the Offer Price text field.
  final TextEditingController priceController = TextEditingController();

  /// Controller for the Offer Date text field.
  final TextEditingController dateController = TextEditingController();

  /// Controller for the Offer Status text field.
  final TextEditingController statusController = TextEditingController();

  /// Initializes the state of the page, drawing the GUI,
  /// and building the database purchase_offer.db.
  /// This then adds all instances of PurchaseOffer in the DB to the list of
  /// viewable Purchase Offers.
  @override
  void initState() {
    super.initState();

    $FloorProjectDatabase.databaseBuilder('purchase_offer.db').build().then(
      (database) {
        purchaseOfferDAO = database.purchaseOfferDAO;

        purchaseOfferDAO.getAllPurchaseOffers().then( (listOfOffers) {
          setState(() {
            offers.addAll(listOfOffers);
          });
        });
      });

  }

  /// Disposes of any active controllers when called.
  @override
  void dispose() {
    super.dispose();
    customerIdController.dispose();
    vehicleIdController.dispose();
    priceController.dispose();
    dateController.dispose();
    statusController.dispose();
  }

  /// Creates and presents to the user a SnackBar with a message appropriate
  /// to the context of when this method was called
  void popSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate(message)!,
            style: myFontStyle,
          ),
        )
    );
  }

  /// Saves the entries in all text fields into EncryptedSharedPreferences prefs,
  /// with appropriate keys for accessing these prefs.
  /// It then performs a check that none of the text fields are empty before
  /// saving the data into both the List offers and the PO DB, and resetting
  /// the values of the text fields.
  Future<void> savePrefs() async {
    prefs.setString("customerIDPref", customerIdController.text);
    prefs.setString("vehicleIDPref", vehicleIdController.text);
    prefs.setString("pricePref", priceController.text);
    prefs.setString("datePref", dateController.text);
    prefs.setString("statusPref", statusController.text);


    setState(() {
      if (
        customerIdController.value.text == "" ||
        vehicleIdController.value.text == "" ||
        priceController.value.text == "" ||
        dateController.value.text == "" ||
        statusController.value.text == ""
      ) {
        popSnackBar("BadEntries");
        return;
      }
      PurchaseOffer newPurchaseOffer = PurchaseOffer(
        PurchaseOffer.ID++, int.parse(customerIdController.value.text),
        int.parse(vehicleIdController.value.text), double.parse(priceController.value.text),
        dateController.value.text, statusController.value.text
      );
      offers.add(newPurchaseOffer);
      purchaseOfferDAO.insertPurchaseOffer(newPurchaseOffer);
      customerIdController.text = "";
      vehicleIdController.text = "";
      priceController.text = "";
      dateController.text = "";
      statusController.text = "";
    });
  }

  /// Loads the saved prefs values into the appropriate text fields for review,
  /// editing, or the re-utilize them for a different entry into the DB and
  /// List offers.
  Future<void> reloadPrefs() async {
    customerIdController.text = await prefs.getString("customerIDPref");
    vehicleIdController.text = await prefs.getString("vehicleIDPref");
    priceController.text = await prefs.getString("pricePref");
    dateController.text = await prefs.getString("datePref");
    statusController.text = await prefs.getString("statusPref");
  }

  /// This Widget actually builds the project page, and holds within it calls to
  /// the other Widgets that it stores: ListPage and DetailsPage, through
  /// the Widget ReactiveLayout.
  /// It possesses an AppBar with several buttons containing instructions for
  /// the page, and toggle buttons for swapping between British English and
  /// American English.
  /// In its center it presents the ReactiveLayout.
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            AppLocalizations.of(context)!.translate("PurchaseOfferListTitle")!,
            style: titleFontStyle,
          ),
          actions: [
            OutlinedButton(onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title:Text(
                      AppLocalizations.of(context)!.translate("PurchaseOfferInstructionsTitle")!,
                      style: titleFontStyle,
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.translate("PurchaseOfferInstructions")!,
                      style: myFontStyle,
                    ),
                    actions: [
                      ElevatedButton(onPressed: () 
                        => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.translate("Close")!,
                          style: buttonFontStyle,
                        )
                      )
                    ],
                  );
              });
            },
              child: Text(
                AppLocalizations.of(context)!.translate("PurchaseOfferInstructionsTitle")!,
                style: buttonFontStyle,
              ),
            ),
            FilledButton(onPressed: () {
                MyApp.setLocale(context, const Locale("en"));
              },
              child: Text(
                AppLocalizations.of(context)!.translate("British")!,
                style: buttonFontStyle,
              ),

            ),
            FilledButton(onPressed: () {
                MyApp.setLocale(context, const Locale("am"));
              },
              child: Text(
                AppLocalizations.of(context)!.translate("American")!,
                style: buttonFontStyle,
              ),
            ),
          ],
        ),
        body: Center (
          child:
          reactiveLayout(),
        )
    );
  }

  /// A nullable Widget with an adjustable view window, depending on a user's
  /// needs, or if they are using a mobile device to view the page.
  /// It calls both Widgets ListPage and DetailsPage, and presents their
  /// appropriate states depending on if there are any POs in the List offers.
  /// It will show DetailsPage for Purchase Offers if one is selected by a user.
  Widget? reactiveLayout() {

    var size = MediaQuery.of(context).size; //checks screen size
    var height = size.height;
    var width = size.width;

    if ((width > height)&&(width > 720)) { //for tablets/Landscape
      return Row(
          children: [
            Expanded(flex: 1, child: ListPage()),
            Expanded(flex: 1, child: DetailsPage())
          ]
      );

    }
    else { //for phone/Portrait
      if (selectedPurchaseOffer == null) {
        return ListPage(); //show List
      }
      else {
        return DetailsPage(); //show Details
      }
    }
  }

  /// This widget presents the details of a selectedPurchaseOffer to the user,
  /// on the right side of the page. This page can be closed, if desired.
  /// It also holds buttons for updating entries in offers and the DB and deleting
  /// entries in offers and the DB.
  /// All updates and deletes are performed in real-time.
  /// Its layout is determined by if there is a selectedPurchaseOffer,
  /// and set using a series of Columns, Paddings, Rows and Buttons.
  Widget DetailsPage() {
    if (selectedPurchaseOffer == null) {
      return Center(child:
        Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                AppLocalizations.of(context)!.translate("OfferSelect")!,
                style: titleFontStyle),
        ])
      );
    }
    else {
      return Center(child:
      Column(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.translate("OfferID")!}"
                  " ${selectedPurchaseOffer!.id} ${AppLocalizations.of(context)!.translate("CustomerID")!}"
                  " ${selectedPurchaseOffer!.customerID}",
                  style: myFontStyle,
                ),
                Text(
                  "${AppLocalizations.of(context)!.translate("VehicleID")!}"
                  " ${selectedPurchaseOffer!.vehicleID} ${AppLocalizations.of(context)!.translate("OfferPrice")!}"
                  " ${selectedPurchaseOffer!.offerPrice}",
                  style: myFontStyle,
                ),
                Text(
                  "${AppLocalizations.of(context)!.translate("OfferDate")!}"
                  " ${selectedPurchaseOffer!.offerDate} ${AppLocalizations.of(context)!.translate("OfferStatus")!}"
                  " ${selectedPurchaseOffer!.offerStatus}",
                  style: myFontStyle,
                ),
                //Spacer(flex: 1),
              ]
            )
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child:
                    Row(crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(onPressed: (){

                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(context)!.translate("DeleteRequest")!,
                                    style: myFontStyle,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context)!.translate("DeleteVerify")!,
                                    style: myFontStyle,
                                  ),
                                  actions: <Widget>[
                                    FilledButton(child:Text(
                                      AppLocalizations.of(context)!.translate("DeleteConfirm")!,
                                      style: buttonFontStyle,
                                    ), onPressed:() {
                                      setState(() {
                                        offers.remove(selectedPurchaseOffer!);
                                        purchaseOfferDAO.deletePurchaseOffer(selectedPurchaseOffer!);
                                        selectedPurchaseOffer = null;
                                      });

                                      Navigator.pop(context);
                                    }),
                                    FilledButton(child:Text(
                                      AppLocalizations.of(context)!.translate("DeleteCancel")!,
                                      style: buttonFontStyle,
                                    ), onPressed:() {
                                      Navigator.pop(context);
                                    }),
                                  ],
                                )
                            );
                          }, child: Text(
                            AppLocalizations.of(context)!.translate("DeleteOffer")!,
                            style: buttonFontStyle,
                          ),
                          ),
                          OutlinedButton(onPressed: () {
                            setState(() {
                              if (customerIdController.value.text != "") {
                                selectedPurchaseOffer!.customerID = int.parse(customerIdController.value.text);
                              }
                              if (vehicleIdController.value.text != "") {
                                selectedPurchaseOffer!.vehicleID = int.parse(vehicleIdController.value.text);
                              }
                              if (priceController.value.text != "") {
                                selectedPurchaseOffer!.offerPrice = double.parse(priceController.value.text);
                              }
                              if (dateController.value.text != "") {
                                selectedPurchaseOffer!.offerDate = dateController.value.text;
                              }
                              if (statusController.value.text != "") {
                                selectedPurchaseOffer!.offerStatus = statusController.value.text;
                              }
                              for (var i = 0; i < offers.length; i++) {
                                if (selectedPurchaseOffer!.id == offers[i].id) {
                                  offers[i] = selectedPurchaseOffer!;
                                }
                              purchaseOfferDAO.updatePurchaseOffer(selectedPurchaseOffer!);
                              }
                              popSnackBar("UpdateConfirm");
                            });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.translate("UpdateOffer")!,
                              style: buttonFontStyle,
                            ),
                          ),
                        ])
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: OutlinedButton(onPressed: (){
                        setState(() {
                          selectedPurchaseOffer = null;
                        });
                      }, child: Text(
                        AppLocalizations.of(context)!.translate("CloseOffers")!,
                        style: buttonFontStyle,
                      ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      );
    }
  }

  /// This widget presents a general list through List offers of
  /// all PurchaseOffer objects to the user. Above this list are the text fields
  /// that a user will fill with this information:
  /// ---Customer ID, Vehicle ID, Offer Price, Offer Date, Offer Status---
  /// If all entries are filled and valid, then a new Purchase Offer is created,
  /// and stored in offers and the PO DB, as well as added to prefs, until
  /// it is overwritten by the new latest entry in the List and DB.
  /// It holds buttons for submitting POs, and reloading saved PO info into the
  /// appropriate text fields.
  /// This recall is performed in real-time and can be used to update an
  /// existing entry, create a new one, or re-apply to a different entry.
  /// It contains a ListView that allows a user to tap (or click) to view
  /// the details of any entries in offers.
  /// Its layout is semi-determined by if there are any PurchaseOffers,
  /// and set using a series of Columns, Paddings, Rows, Flexibles and Buttons.
  Widget ListPage(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Flexible( flex:2, child:TextField(
                      controller: customerIdController, decoration: InputDecoration(
                      hintText:
                        AppLocalizations.of(context)!.translate("UserIDHint")!,
                      border: OutlineInputBorder())
                  )
                  ),
                  Flexible( flex:2, child:TextField(
                      controller: vehicleIdController, decoration: InputDecoration(
                      hintText:
                        AppLocalizations.of(context)!.translate("VehicleIDHint")!,
                      border: OutlineInputBorder())
                  )
                  ),
                  Flexible( flex:2, child:TextField(
                      controller: priceController, decoration: InputDecoration(
                      hintText:
                        AppLocalizations.of(context)!.translate("OfferPriceHint")!,
                      border: OutlineInputBorder())
                  )
                  ),
                ]
            ),
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                Flexible(flex: 2, child:TextField(
                  controller: dateController, decoration: InputDecoration(
                  hintText:
                    AppLocalizations.of(context)!.translate("OfferDateHint")!,
                  border: OutlineInputBorder())
                )
                ),
                Flexible( flex:2, child:TextField(
                  controller: statusController, decoration: InputDecoration(
                  hintText:
                    AppLocalizations.of(context)!.translate("OfferStatusHint")!,
                  border: OutlineInputBorder())
                )
                ),
              ]
            ),
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child:Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              ElevatedButton( child:Text(
                AppLocalizations.of(context)!.translate("PurchaseOfferSubmit")!,
                style: buttonFontStyle,
                ), onPressed:() => savePrefs(),
              ),
            ]),
          ),
          Expanded(child:
          (offers.isEmpty) ? //if true condition
          Text(
            AppLocalizations.of(context)!.translate("NoPurchaseOffers")!,
            style: myFontStyle,
          )
            : //else, or false condition
          ListView.builder(
            shrinkWrap: true,
            itemCount: offers.length,
            itemBuilder:(context, rowNum) =>
              GestureDetector(child: Center(
                child:Text(
                  "${rowNum+1}: ${AppLocalizations.of(context)!.translate("OfferID")!} ${offers[rowNum].id}",
                  style: myFontStyle,
                ),
                ),
                  onTap: () {
                    setState(() {
                      selectedPurchaseOffer = offers[rowNum];
                    });
                  },
              )
          )
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child:
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: () => reloadPrefs(),
                  child: Text(
                    AppLocalizations.of(context)!.translate("ReloadOffer")!,
                    style:buttonFontStyle,
                  )),
              ],
            )
          ),
        ]);
  }
}