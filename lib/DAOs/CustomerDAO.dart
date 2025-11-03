import 'package:floor/floor.dart';
import '../models/Customer.dart';

@dao
abstract class CustomerDAO{

  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  @Query('SELECT * FROM Customer WHERE id = :id')
  Future<Customer?> getCustomerByID(int id);

  @insert
  Future<void> insertCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);

}