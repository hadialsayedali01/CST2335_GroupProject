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
  var buttonFontStyle = TextStyle(fontSize: 15, color: Colors.black);

  Widget? ListPage(){
    return null;
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
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Purchase info...", style: titleFontStyle)
                ]
            )
        )
    );
  }

}