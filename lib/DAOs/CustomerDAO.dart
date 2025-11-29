import 'package:floor/floor.dart';
import '../models/Customer.dart';

/// Data Access Object for managing [Customer] entity.
@dao
abstract class CustomerDAO {
  /// Retrieves all customers from the database.
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  /// Retrieves a specific customer by their [id].
  @Query('SELECT * FROM Customer WHERE id = :id')
  Future<Customer?> getCustomerByID(int id);

  /// Inserts a new [customer] into the database.
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Updates an existing [customer] in the database.
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a specific [customer] from the database.
  @delete
  Future<void> deleteCustomer(Customer customer);
}
