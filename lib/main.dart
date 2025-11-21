import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'AppLocalizations.dart';

import 'BoatsForSalePage.dart';
import 'CarsForSalePage.dart';
import 'CustomerListPage.dart';
import 'PurchaseOfferPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  MyAppState createState(){
    return MyAppState();
  }
}

class MyAppState extends State<MyApp>{
  var _locale = Locale("en", "CA");
  void changeLanguage(Locale locale){
    setState(
        (){
          _locale = locale;
        }
    );
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      supportedLocales: [
        Locale("en", "CA"),
        Locale("fr")
      ],
      localizationsDelegates: const [ 
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: _locale,
      routes: {
        'customerList' : (context) => CustomerListPage(),
        'carsForSale' : (context) => CarsForSalePage(),
        'boatsForSale' : (context) => BoatsForSalePage(),
        'purchaseOffer' : (context) => PurchaseOfferPage()
      },
      title: 'CST2355 Group Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useSystemColors: true,
      ),
      home: const MyHomePage(title: 'CST2355 Group Project'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var homeButtonPadding = 5.0;
  var homeButtonTextStyle = TextStyle(fontSize: 30, color: Colors.black);
  var homeButtonFixedWidth = 300.0;

  /// This method returns a formatted button that leads to one of the four application pages.
  /// It takes a String routeName parameter for the name of the route to navigate to.
  /// It takes a String buttonText parameter for the displayed text on the button.
  Widget? returnFormattedHomeButton(String? routeName, String? buttonText){
    return Padding(
        padding: EdgeInsets.all(homeButtonPadding),
        child: Container(
            width: homeButtonFixedWidth,
            child:ElevatedButton(
                onPressed: (){Navigator.pushNamed(context, routeName!);},
                child: Text(buttonText!, style: homeButtonTextStyle)
            )
        )
    );
  }

  /// This method returns a circular-formatted image.
  /// It takes a String imageSource parameter that is the path of the image.
  Widget? returnFormattedImage(String? imageSource){
    return Padding(
      padding: EdgeInsets.all(15),
      child: CircleAvatar(
          radius: 150,
          backgroundImage: AssetImage(
              imageSource!
          )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // images row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:[
                returnFormattedImage('images/boat.jpg')!,
                returnFormattedImage('images/car.jpg')!
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                returnFormattedHomeButton("boatsForSale" , "Boat List")!,
                returnFormattedHomeButton("carsForSale" , "Car List")!,
              ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  returnFormattedHomeButton("customerList" , "Customer List")!,
                  returnFormattedHomeButton("purchaseOffer" , "Purchase Offer")!
                ]
            )
          ]
        )
      )
    );
  }
}
