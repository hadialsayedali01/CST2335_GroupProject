import 'package:flutter/material.dart';
import 'package:project_test/ProjectDatabase.dart';
import 'models/Customer.dart';
import 'DAOs/CustomerDAO.dart';

class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomerListPageState();
  }
}

class CustomerListPageState extends State<CustomerListPage> {

  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController dateOfBirthController = TextEditingController();
  late TextEditingController driversLicenseController = TextEditingController();

  Customer? selectedCustomer = null;

  List<Customer> customers = [];

  late CustomerDAO customerDAO;

  bool formOpenFlag = false;

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
          customerDAO.insertCustomer(Customer(Customer.ID++,"Hadi","Ali","123 Home St","123 sdfas", "123 AAA"));
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
    setState(
        (){
          //customerDAO.updateCustomer(customer)
        }
    );
  }

  void addCustomer(){
    setState(
            (){
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
          firstNameController.text="";
          lastNameController.text="";
          addressController.text="";
          dateOfBirthController.text="";
          driversLicenseController.text="";
        }
    );
  }

  void removeCustomerByRowNum(rowNum){
    setState(
            (){
          customerDAO.deleteCustomer(customers[rowNum]);
          customers.removeAt(rowNum);
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
      case "add":
        return ElevatedButton(child: Text("Add"), onPressed:(){addCustomer();});
      case "remove":
        return ElevatedButton(child: Text("Remove"), onPressed:(){removeCustomerByObject(selectedCustomer!);});
      case "update":
        return ElevatedButton(child: Text("Update"), onPressed:(){});
      case "close":
        return ElevatedButton(child: Text("Close"), onPressed:(){setState((){selectedCustomer=null; formOpenFlag=false;});});
      default:
        return null;
    }


  }

  Widget DetailsPage(){
    // If a customer is not selected, display the form for entering a customer
    if (selectedCustomer == null){
      firstNameController.text = "";
      lastNameController.text = "";
      addressController.text = "";
      dateOfBirthController.text = "";
      driversLicenseController.text = "";
      return Column(
        children: [
          returnOneController(firstNameController, "First Name"),
          returnOneController(lastNameController, "Last Name"),
          returnOneController(addressController, "Address"),
          returnOneController(dateOfBirthController, "Date of Birth"),
          returnOneController(driversLicenseController, "Driver's License"),
          returnButtonType("add")!,
          returnButtonType("close")!
        ]
      );
    }
    // if customer is selected, show that customer's info in the forms
    else {
      firstNameController.text = selectedCustomer!.firstName;
      lastNameController.text = selectedCustomer!.lastName;
      addressController.text = selectedCustomer!.address;
      dateOfBirthController.text = selectedCustomer!.dateOfBirth;
      driversLicenseController.text = selectedCustomer!.driversLicense;
      return Column (
        children: [
          returnOneController(firstNameController, "First Name"),
          returnOneController(lastNameController, "Last Name"),
          returnOneController(addressController, "Address"),
          returnOneController(dateOfBirthController, "Date of Birth"),
          returnOneController(driversLicenseController, "Driver's License"),
          returnButtonType("remove")!,
          returnButtonType("update")!,
          returnButtonType("close")!
        ]
      );
    }
  }

  Widget ListPage() {
    if (customers.isEmpty) {
      return Column(
        children: [
          Text("There are no customers in the list."),
          ElevatedButton(
            child: Text("Add New Customer"),
            onPressed: () {
              setState(() {
                formOpenFlag = true;
              });
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text("Add New Customer"),
              onPressed: () {
                setState(() {
                  formOpenFlag = true;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, rowNum) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCustomer = customers[rowNum];
                      formOpenFlag = false;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${rowNum + 1}: ${customers[rowNum].firstName} ${customers[rowNum].lastName}",
                        ),
                      ],
                    ),
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