import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:project_test/AppLocalizations.dart';
import 'package:project_test/ProjectDatabase.dart';
import 'main.dart';
import 'models/Customer.dart';
import 'DAOs/CustomerDAO.dart';

class DataRepository {
  static EncryptedSharedPreferences encSP = EncryptedSharedPreferences();

  static String? firstName;
  static String? lastName;
  static String? address;
  static String? driversLicense;
  static String? dateOfBirth;

  static void loadData() async {
    firstName = await encSP.getString("firstName");
    lastName = await encSP.getString("lastName");
    address = await encSP.getString("address");
    dateOfBirth = await encSP.getString("dateOfBirth");
    driversLicense = await encSP.getString("driversLicense");
  }

  static void saveDate(){
    encSP.setString("firstName", firstName!);
    encSP.setString("lastName", lastName!);
    encSP.setString("address", address!);
    encSP.setString("dateOfBirth", dateOfBirth!);
    encSP.setString("driversLicense", driversLicense!);
  }
}

/// This represents the customer list page, where the end user can add, update, and remove customers.
/// @author alsa0280
/// @version 1.0
class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomerListPageState();
  }
}

/// This represents the state of the customer list page, where page components are controlled.
/// @author alsa0280
/// @version 1.0
class CustomerListPageState extends State<CustomerListPage> {

  /// The text controller for entering/updating a customer's first name.
  late TextEditingController firstNameController = TextEditingController();
  /// The text controller for entering/updating a customer's last name.
  late TextEditingController lastNameController = TextEditingController();
  /// The text controller for entering/updating a customer's address.
  late TextEditingController addressController = TextEditingController();
  /// The text controller for entering/updating a customer's date of birth.
  late TextEditingController dateOfBirthController = TextEditingController();
  /// The text controller for entering/updating a customer's driver's license.
  late TextEditingController driversLicenseController = TextEditingController();

  Customer? selectedCustomer = null;

  List<Customer> customers = [];

  late CustomerDAO customerDAO;

  bool formOpenFlag = false;

  String potentialErrorMessage = "";

  @override
  void initState(){
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    addressController = TextEditingController();
    dateOfBirthController = TextEditingController();
    driversLicenseController = TextEditingController();
    $FloorProjectDatabase.databaseBuilder('customer_database.db').build().then(
            (database){
          customerDAO = database.customerDAO;
          customerDAO.getAllCustomers().then(
                  (allCustomers){
                setState(
                        (){
                      customers = allCustomers;
                    }
                );
              }
          );
        }
    );
  }

  @override
  void dispose(){
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    dateOfBirthController.dispose();
    driversLicenseController.dispose();
  }

  //layout methods
  Widget responsiveLayout(){
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //If landscape and customer NOT selected, show listview
    if ((width>height) && (width>720)){
      if (selectedCustomer!=null || formOpenFlag){
        // If landsacep and customer selected, show both
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child:ListPage()),
              Expanded(child:DetailsPage())
            ]
        );
      }
      else {
        return ListPage();
      }
    }
    // if in potrait mode
    else {
      if (selectedCustomer!=null || formOpenFlag){
        //just show listview
        return DetailsPage();
      }
      else {
        //just show detailsPage
        return ListPage();
      }
    }

  }

  // helper methods
  void updateCustomer(){
    setState (
        (){
          //update the fields for selectedCustomer
          selectedCustomer!.driversLicense=driversLicenseController.value.text;
          selectedCustomer!.firstName=firstNameController.value.text;
          selectedCustomer!.lastName=lastNameController.value.text;
          selectedCustomer!.address=addressController.value.text;
          selectedCustomer!.dateOfBirth=dateOfBirthController.value.text;
          customerDAO.updateCustomer(selectedCustomer!).then(
                  (dummyParam){
                setState((){
                  customerDAO.getAllCustomers().then((dbList){
                    customers=dbList;
                  });
                });
              }
          );
          selectedCustomer = null;
          formOpenFlag = false;
          DataRepository.saveDate();
          resetFields();
        }
    );
    }


  void placeDataInRepository(){
    DataRepository.firstName=firstNameController.value.text;
    DataRepository.lastName=lastNameController.value.text;
    DataRepository.address=addressController.value.text;
    DataRepository.dateOfBirth=dateOfBirthController.value.text;
    DataRepository.driversLicense=driversLicenseController.value.text;
  }

  void loadLastCustomer() {
    DataRepository.loadData();
    if (DataRepository.firstName!=null) {
      setState(
              (){
            firstNameController.text = DataRepository.firstName!;
            lastNameController.text = DataRepository.lastName!;
            addressController.text = DataRepository.address!;
            dateOfBirthController.text = DataRepository.dateOfBirth!;
            driversLicenseController.text = DataRepository.driversLicense!;
          }
      );
    }
  }

  void addCustomer(){
    if (verifyFields()){
      placeDataInRepository();
      DataRepository.saveDate();
      setState(
              () {
            Customer? newCustomer = Customer(
                Customer.ID++,
                firstNameController.value.text,
                lastNameController.value.text,
                addressController.value.text,
                dateOfBirthController.value.text,
                driversLicenseController.value.text
            );
            customers.add(newCustomer);
            customerDAO.insertCustomer(newCustomer);

            selectedCustomer = null;
            formOpenFlag = false;
            resetFields();
          }
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar (
          content: Text(AppLocalizations.of(context)!.translate('CustomerAdded')!)
      ));
    }

  }

  void removeCustomerByRowNum(rowNum){
    setState(
            (){
          customerDAO.deleteCustomer(customers[rowNum]);
          customers.removeAt(rowNum);
          resetFields();
          Navigator.pop(context);
        }
    );
  }

  void removeCustomerByObject(Customer customer){
    setState(
            (){
          customerDAO.deleteCustomer(customer);
          customers.remove(customer);
          selectedCustomer = null;
          resetFields();
        }
    );
  }

  Widget someDetail(String label){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label)
      ],
    );
  }

  Widget? returnButtonType(String type){
    switch (type){
      case "load":
        return ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('LoadLastCustomer')!), onPressed: (){loadLastCustomer();});
      case "reset":
        return ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('ResetFields')!), onPressed: (){resetFields();});
      case "add":
        return ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('Add')!), onPressed:(){addCustomer();});
      case "remove":
        return ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('Remove')!), onPressed:(){removeCustomerByObject(selectedCustomer!); potentialErrorMessage="";});
      case "update":
        return ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('Update')!), onPressed:(){updateCustomer(); potentialErrorMessage="";});
      case "close":
        return ElevatedButton(child: Text(AppLocalizations.of(context)!.translate('Close')!), onPressed:(){setState((){selectedCustomer=null; formOpenFlag=false; potentialErrorMessage="";});});
      default:
        return null;
    }


  }

  bool verifyFields(){
    if (
      firstNameController.value.text == "" ||
      lastNameController.value.text == "" ||
          addressController.value.text == ""
    ){
      setState(
          (){
            potentialErrorMessage = AppLocalizations.of(context)!.translate("EmptyFields")!;
          }
      );
      return false;
    }
    else {
      setState(
              (){
            potentialErrorMessage = AppLocalizations.of(context)!.translate("EmptyFields")!;
          }
      );
      return true;
    }
  }

  void loadSelectedCustomer(){
    setState(
        (){
          firstNameController.text = selectedCustomer!.firstName;
          lastNameController.text = selectedCustomer!.lastName;
          addressController.text = selectedCustomer!.address;
          dateOfBirthController.text = selectedCustomer!.dateOfBirth;
          driversLicenseController.text = selectedCustomer!.driversLicense;
        }
    );
  }

  void resetFields() {
    setState(
            (){
          firstNameController.text = "";
          lastNameController.text = "";
          addressController.text = "";
          dateOfBirthController.text = "";
          driversLicenseController.text = "";
        }
    );
  }


  Widget DetailsPage() {
    // If no customer selected → show blank entry form
    if (selectedCustomer == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          returnButtonType("load")!,
          returnButtonType("reset")!,
          returnOneController(firstNameController, AppLocalizations.of(context)!.translate("FirstName")!),
          returnOneController(lastNameController, AppLocalizations.of(context)!.translate("LastName")!),
          returnOneController(addressController, AppLocalizations.of(context)!.translate("Address")!),
          returnOneController(dateOfBirthController, AppLocalizations.of(context)!.translate("DateOfBirth")!),
          returnOneController(driversLicenseController, AppLocalizations.of(context)!.translate("DriversLicense")!),
          returnButtonType("add")!,
          returnButtonType("close")!,
          Text(potentialErrorMessage, style:TextStyle(color:Colors.red)),
        ],
      );
    }

    // If a customer *is* selected → show editable form
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        returnOneController(firstNameController, AppLocalizations.of(context)!.translate('FirstName')!),
        returnOneController(lastNameController, AppLocalizations.of(context)!.translate('LastName')!),
        returnOneController(addressController, AppLocalizations.of(context)!.translate('Address')!),
        returnOneController(dateOfBirthController, AppLocalizations.of(context)!.translate('DateOfBirth')!),
        returnOneController(driversLicenseController, AppLocalizations.of(context)!.translate('DriversLicense')!),
        returnButtonType("remove")!,
        returnButtonType("update")!,
        returnButtonType("close")!,
        Text(potentialErrorMessage),
      ],
    );
  }


  Widget ListPage() {
    if (customers.length==0) {
      return
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding:EdgeInsets.all(5), child: Text(AppLocalizations.of(context)!.translate('NoCustomer')!)),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.translate('AddNewCustomer')!),//AppLocalizations.of(context)!.translate("AddNewCustomer")!),
                onPressed: () {
                  setState(() {
                    resetFields();
                    formOpenFlag = true;
                  });
                },
              ),
            ],
          )
        );
    } else {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              child: Text(AppLocalizations.of(context)!.translate('AddNewCustomer')!),
              onPressed: () {
                setState(() {
                  resetFields();
                  formOpenFlag = true;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, rowNum) {
                return Padding(
                    padding: EdgeInsets.fromLTRB(200,5,200,5),
                    child: ElevatedButton(
                        onPressed:(){
                          setState(() {
                            selectedCustomer = customers[rowNum];
                            loadSelectedCustomer();
                            formOpenFlag = false;
                          });
                        },
                        child:Text(
                          "${rowNum + 1}: ${customers[rowNum].lastName}, ${customers[rowNum].firstName}"
                        ),
                      //],
                    ),
                  );
              },
            ),
          ),
        ],
      );
    }
  }


  Widget returnOneController(TextEditingController controller, String label){
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child:TextField(controller: controller, decoration: InputDecoration(border: OutlineInputBorder(), hintText: label)))
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("CustomerListTitle")!),
        actions: [
          OutlinedButton(onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.translate("InstructionsTitle")!),
                    content: Text(AppLocalizations.of(context)!.translate("FullInstructions")!),
                    actions: [ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text(AppLocalizations.of(context)!.translate("Close")!))]
                  );
                });
          }, child: Text(AppLocalizations.of(context)!.translate("InstructionsTitle")!)),
          FilledButton(onPressed:(){MyApp.setLocale(context, Locale("en"));}, child: Text(AppLocalizations.of(context)!.translate("English")!)),
          FilledButton(onPressed:(){MyApp.setLocale(context, Locale("fr"));}, child: Text(AppLocalizations.of(context)!.translate("French")!))
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,

      ),
      body: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child:responsiveLayout())
        ],
      ),
    );
  }
}