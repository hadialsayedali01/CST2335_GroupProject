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

  var titleFontStyle = TextStyle(fontSize: 20);
  var buttonFontStyle = TextStyle(fontSize: 15, color: Colors.black);

  var customers = <Customer>[];

  late CustomerDAO dao;

  @override
  void initState(){
    super.initState();
    $FloorProjectDatabase
          .databaseBuilder('ProjectDatabase')
          .build()
          .then(
        (database){
          dao = database.customerDAO;
          dao.insertCustomer(Customer(Customer.ID++, "Hadi", "Ali", "12313 Home ST", '2001-01-01', 'H1H1H1'));
          dao.getAllCustomers().then(
              (customerList){
                setState(
                    () {
                      customers.addAll(customerList);
                      print(customers[0].firstName);
                    }
                );
              }
          );
        }
    );
  }

  Widget ListPage(){
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, rowNum){
        return Row(
          children: [
            Text(customers[0].firstName)
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Customer List")
      ),
        body: Center (
            child:
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: ListPage())
                ]
            )
        )
    );
  }

}