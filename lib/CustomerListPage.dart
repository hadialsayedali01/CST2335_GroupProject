import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:project_test/AppLocalizations.dart';
import 'package:project_test/ProjectDatabase.dart';
import 'main.dart';
import 'models/Customer.dart';
import 'DAOs/CustomerDAO.dart';

/// This class holds the EncryptedShared preferences instance, exposing methods for loading and saving data to and from it.
/// @author Hadi Al-Sayed Ali
/// @version 1.0
class DataRepository {

  /// The EncryptedSharedPreferences instance, which holds the previously added customer's information.
  static EncryptedSharedPreferences encSP = EncryptedSharedPreferences();

  /// The first name of the previously added customer.
  static String? firstName;
  /// The last name of the previously added customer.
  static String? lastName;
  /// The address of the previously added customer.
  static String? address;
  /// The driver's license of the previously added customer.
  static String? driversLicense;
  /// The date of birth of the previously added customer.
  static String? dateOfBirth;

  /// This method loads the previously added customer's data into the static class variables
  static void loadData() async {
    firstName = await encSP.getString("firstName");
    lastName = await encSP.getString("lastName");
    address = await encSP.getString("address");
    dateOfBirth = await encSP.getString("dateOfBirth");
    driversLicense = await encSP.getString("driversLicense");
  }

  /// This method saves the static class variables representing customer data into the EncryptedSharedPreferences instance
  static void saveDate(){
    encSP.setString("firstName", firstName!);
    encSP.setString("lastName", lastName!);
    encSP.setString("address", address!);
    encSP.setString("dateOfBirth", dateOfBirth!);
    encSP.setString("driversLicense", driversLicense!);
  }
}

/// This represents the customer list page, where the end user can add, update, and remove customers.
/// @author Hadi Al-Sayed Ali
/// @version 1.0
class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomerListPageState();
  }
}

/// This represents the state of the customer list page, where page components are controlled.
/// @author Hadi Al-Sayed Ali
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

  /// Holds the information of the customer currently selected by the user (null if one is not selected).
  Customer? selectedCustomer = null;

  /// Holds the list of all customers.
  List<Customer> customers = [];

  /// This object provides the state with a means of querying the database for customer information.
  late CustomerDAO customerDAO;

  /// This indicates whether the customer form should be open.
  bool formOpenFlag = false;

  /// This holds a potential error message, whose value depends on whether the user left any fields empty.
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

  /// This method sets the page layout in accordance with the media size and whether a customer has been selected.
  Widget responsiveLayout(){
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if ((width>height) && (width>720)){
      if (selectedCustomer!=null || formOpenFlag){
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
    else {
      if (selectedCustomer!=null || formOpenFlag){
        return DetailsPage();
      }
      else {
        return ListPage();
      }
    }

  }

  /// This method updates the static class variables of the DataRepository with the values that are currently in the text fields.
  void placeDataInRepository(){
    DataRepository.firstName=firstNameController.value.text;
    DataRepository.lastName=lastNameController.value.text;
    DataRepository.address=addressController.value.text;
    DataRepository.dateOfBirth=dateOfBirthController.value.text;
    DataRepository.driversLicense=driversLicenseController.value.text;
  }

  /// This method updates the text fields with the values of the static class variables in the DataRepository; i.e., the last-added customer values.
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

  /// This method adds a customer to a database and saves their data to the EncryptedSharedPreferences instance, showing a SnackBar to update the user.
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

  /// This method updates a selected customer by calling the appropriate DAO method, then saves the data to EncryptedSharedPreferences.
  void updateCustomer(){
    setState (
            (){
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

  /// This method removes a customer from the database.
  /// It has a Customer object parameter; this is the customer that will be removed.
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

  /// This method dynamically returns specific types of buttons for use within the DetailsPage.
  /// It takes a String type parameter that specifies the type of button to return.
  /// It returns a potentially null Widget that is the returned button.
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

  /// This method redraws the state to show the error message, depending on whether the user left the fields empty.
  /// It returns a bool value (true if the fields are valid, false if the fields are invalid).
  bool verifyFields(){
    if (
      firstNameController.value.text == "" ||
      lastNameController.value.text == "" ||
      addressController.value.text == "" ||
      driversLicenseController.value.text == "" ||
      dateOfBirthController.value.text == ""
    ){
      setState(
          (){
            potentialErrorMessage = AppLocalizations.of(context)!.translate("EmptyFields")!;
          }
      );
      return false;
    }
    else {
      return true;
    }
  }

  /// This method is called to load the user-selected customer's details into the form fields.
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

  /// This method resets/empties the customer form's text fields.
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


  /// This method displays a form where the user can enter, update, or delete a customer.
  /// The method returns a Column of the customer form, including its text fields and a set of context-dependent buttons.
  Widget DetailsPage() {
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

  /// This method displays a clickable list of current customers in the database.
  /// This method returns a Widget consisting of either customers in the database or a message stating that there are no customers.
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

  /// This method dynamically returns text fields for displays with specified labels, for use in DetailsPage.
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