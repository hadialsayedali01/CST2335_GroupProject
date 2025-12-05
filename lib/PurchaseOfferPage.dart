import 'dart:ffi';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'ProjectDatabase.dart';
import 'main.dart';
import 'models/PurchaseOffer.dart';
import 'DAOs/PurchaseOfferDAO.dart';

class PurchaseOfferPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PurchaseOfferPageState();
  }

}

class PurchaseOfferPageState extends State<PurchaseOfferPage> {

  var titleFontStyle = TextStyle(fontSize: 20);
  var myFontStyle = TextStyle(fontSize: 18);
  var buttonFontStyle = TextStyle(fontSize: 15, color: Colors.black);

  late PurchaseOfferDAO purchaseOfferDAO;

  List<PurchaseOffer> offers = [];

  PurchaseOffer? selectedPurchaseOffer;

  final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

  final TextEditingController customerIdController = TextEditingController();

  final TextEditingController vehicleIdController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController dateController = TextEditingController();

  final TextEditingController statusController = TextEditingController();

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

  @override
  void dispose() {
    super.dispose();
    customerIdController.dispose();
    vehicleIdController.dispose();
    priceController.dispose();
    dateController.dispose();
    statusController.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("Purchase List")
        ),
        body: Center (
            child:
            reactiveLayout(),
//            Column(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: [
//                  Text("Purchase info...", style: titleFontStyle)
//                ]
//            )
        )
    );
  }

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

  Widget DetailsPage() {
    if (selectedPurchaseOffer == null) {
      return Center(child:
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select a Purchase Offer for more details", style: myFontStyle),
        ])
      );
    }
    else {
      return Center(child:
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Offer ID: ${selectedPurchaseOffer!.id}", style: myFontStyle),
        Text("Customer ID: ${selectedPurchaseOffer!.customerID}", style: myFontStyle),
        Text("Vehicle ID: ${selectedPurchaseOffer!.vehicleID}", style: myFontStyle),
        Text("Offer Price: ${selectedPurchaseOffer!.offerPrice}", style: myFontStyle),
        Text("Offer Date: ${selectedPurchaseOffer!.offerDate}", style: myFontStyle),
        Text("Offer Status: ${selectedPurchaseOffer!.offerStatus}", style: myFontStyle),
        Spacer(),
        OutlinedButton(onPressed: (){

          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Delete this item from the list?'),
                content: const Text('Are you sure?'),
                actions: <Widget>[
                  FilledButton(child:Text("Confirm Delete"), onPressed:() {
                    setState(() {
                      //Item delItem = Item(list1[rowNum].id, list1[rowNum].name, list1[rowNum].quantity);
                      offers.remove(selectedPurchaseOffer!);
                      purchaseOfferDAO.deletePurchaseOffer(selectedPurchaseOffer!);
                      selectedPurchaseOffer = null;
                    });

                    Navigator.pop(context);
                  }),
                  FilledButton(child:Text("Cancel Delete"), onPressed:() {
                    Navigator.pop(context);

                  }),
                ],
              )
          );
        }, child: Text("Delete Item")),
        OutlinedButton(onPressed: (){
          setState(() {
            selectedPurchaseOffer = null;
          });
        }, child: Text("Close Details")),
      ]
      )
      );
    }
    //return Text("Details");
  }

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
                      hintText:"User ID", border: OutlineInputBorder())
                  )
                  ),
                  Flexible( flex:2, child:TextField(
                      controller: vehicleIdController, decoration: InputDecoration(
                      hintText:"Vehicle ID", border: OutlineInputBorder())
                  )
                  ),
                  Flexible( flex:2, child:TextField(
                      controller: priceController, decoration: InputDecoration(
                      hintText:"Offer Price", border: OutlineInputBorder())
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
                    hintText:"Date of Offer (DD/MM/YYYY)", border: OutlineInputBorder())
                )
                ),
                Flexible( flex:2, child:TextField(
                  controller: statusController, decoration: InputDecoration(
                  hintText:"Accepted or Rejected?", border: OutlineInputBorder())
                )
                ),
              ]
            ),
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child:Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              ElevatedButton( child:Text("Submit Purchase Offer"), onPressed:() {
              setState(() {
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
              }),
            ]),
          ),
          Expanded(child:
          (offers.isEmpty) ? //if true condition
          Text("There are no Purchase Offers")
              : //else, or false condition
          ListView.builder(
              shrinkWrap: true,
              itemCount: offers.length,
              itemBuilder:(context, rowNum) =>
                  GestureDetector(child: Center(
                      child:Text(
                          "${rowNum+1}: Offer ID: ${offers[rowNum].id} Customer ID: ${offers[rowNum].customerID}"
                              "Vehicle ID: ${offers[rowNum].vehicleID} Offer Price: ${offers[rowNum].offerPrice}"
                              "Date of Offer: ${offers[rowNum].offerDate} Offer Status: ${offers[rowNum].offerStatus}")) ,

                      onTap: () {
                        setState(() {
                          selectedPurchaseOffer = offers[rowNum];
                        });
                      },

                      onLongPress: () {

                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Delete this item from the list?'),
                              content: const Text('Are you sure?'),
                              actions: <Widget>[
                                FilledButton(child:Text("Confirm Delete"), onPressed:() {
                                  setState(() {
                                    PurchaseOffer delPurchaseOffer = PurchaseOffer(
                                        offers[rowNum].id, offers[rowNum].customerID, offers[rowNum].vehicleID,
                                        offers[rowNum].offerPrice, offers[rowNum].offerDate, offers[rowNum].offerStatus
                                    );
                                    offers.removeAt(rowNum);
                                    purchaseOfferDAO.deletePurchaseOffer(delPurchaseOffer);
                                  });

                                  Navigator.pop(context);
                                }),
                                FilledButton(child:Text("Cancel Delete"), onPressed:() {
                                  Navigator.pop(context);
                                }),
                              ],
                            )
                        );
                      })
          )
          ),
        ]);
  }
}